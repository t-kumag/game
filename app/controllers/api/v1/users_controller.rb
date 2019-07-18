class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: [:at_url, :at_sync, :at_token, :destroy, :at_sync_test]
  before_action :check_temporary_user, only: [:create]

  def create

    begin
      @user = Entities::User.new
      @user.email = sign_up_params[:email]
      @user.password = sign_up_params[:password]
      @user.email_authenticated = false
      @user.reset_token
      @user.save!
      MailDelivery.user_registration(@user).deliver
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    render 'create', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def resend
    obj = {}
    user = Entities::User.where(email: params[:email]).first

    unless user.email_authenticated
      user.reset_token
      user.save!
      MailDelivery.user_registration(user).deliver

      render json: obj, status: 200
    else
      render json: obj, status: :bad_request
    end
  end

  def activate
    user = Entities::User.where(token: params[:token]).first
    return render_forbidden if user.blank?
    user.reset_token
    user.email_authenticated = true
    user.save!
    @response = user
    render 'activate', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def change_password_request
    user = Entities::User.where(email: params[:email]).first

    if user.present?
      user.change_password_reset_token
      user.save!
      MailDelivery.user_change_password_request(user).deliver

      render json: {}, status: 200
    else
      render json: { errors: { code: '', message: "email not found." } }, status: 422
    end
  end

  def change_password
    current_user = Entities::User.token_authenticate!(params[:token])
    change_status = false

    if change_password_params[:password].present? && change_password_params[:password_confirm].present?
      change_status = change_password_params[:password] == change_password_params[:password_confirm]
    else
      render json: { errors: { code: '', message: "empty password." } }, status: 422 and return
    end

    if current_user.present? && DateTime.now <= current_user.token_expires_at && change_status
      current_user.password = change_password_params[:password]
      current_user.reset_token
      current_user.save!
      render json: {}, status: 200
    else
      render json: { errors: { code: '', message: "user not found or invalid token." } }, status: 422
    end
  end

  def at_url
    @response = Services::AtUserService.new(@current_user).at_url
    render 'at_url', formats: 'json', handlers: 'jbuilder'
  end

  def at_sync
    at_user_service = Services::AtUserService.new(@current_user, params[:target])
    at_user_service.exec_scraping
    at_user_service.sync

    puts 'user_distributed_transactions sync=========='
    Services::UserDistributedTransactionService.new(@current_user, params[:target]).sync

    render json: {}, status: 200
  end

  def at_sync_test
    AtSyncWorker.perform_async(@current_user.id, params[:target])
    render json: {}, status: 200
  end

  def at_token
    @response = Services::AtUserService.new(@current_user).token
    render 'at_token', formats: 'json', handlers: 'jbuilder'
  end

  def destroy

    cancel_reason = delete_user_params[:user_cancel_reason]
    cancel_checklists = delete_user_params[:user_cancel_checklists]
    at_user_bank_account_ids = @current_user&.try(:at_user)&.try(:at_user_bank_accounts)&.pluck(:id)
    at_user_card_account_ids = @current_user&.try(:at_user)&.try(:at_user_card_accounts)&.pluck(:id)
    at_user_emoney_service_account_ids = @current_user&.try(:at_user)&.try(:at_user_emoney_service_accounts)&.pluck(:id)

    # TODO: バリデーション
    # TODO 例外処理と共通化
    # 削除されるテーブル
    # at_users, at_usuer_tokens, users, at_user_xxxx_accounts
    begin
      ActiveRecord::Base.transaction do
        if cancel_checklists.present?
          Services::UserCancelAnswerService.new(@current_user).register_cancel_checklist(cancel_checklists)
          Services::UserCancelReasonService.new(@current_user).register_cancel_reason(cancel_reason) if cancel_reason.present?
          Services::ParingService.new(@current_user).cancel
          delete_at_user_account(at_user_bank_account_ids, at_user_card_account_ids, at_user_emoney_service_account_ids)
          # ユーザー削除
          @current_user.at_user.destroy
          @current_user.clear_token
          @current_user.delete
          @current_user = nil
        else
          render json: {}, status: :bad_request and return
        end
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
    render json: {}, status: 200
  end

  private
  def sign_up_params
    params.permit(:email, :password)
  end

  def delete_user_params
    params.permit(:user_cancel_reason, user_cancel_checklists: [])
  end

  def change_password_params
    params.permit(:password, :password_confirm)
  end


  def delete_at_user_account(at_user_bank_account_ids, at_user_card_account_ids, at_user_emoney_service_account_ids)

    if at_user_bank_account_ids.present?
      Services::AtUserService.new(@current_user).delete_account(Entities::AtUserBankAccount, at_user_bank_account_ids)
    end

    if at_user_card_account_ids.present?
      Services::AtUserService.new(@current_user).delete_account(Entities::AtUserCardAccount, at_user_card_account_ids)
    end

    if at_user_emoney_service_account_ids.present?
      Services::AtUserService.new(@current_user).delete_account(Entities::AtUserEmoneyServiceAccount, at_user_emoney_service_account_ids)
    end

  end
end
