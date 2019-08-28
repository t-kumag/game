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
    unless change_password_params[:password].present?
      render_400_invalid_validation([{resource: 'User', field: 'password', code: 'empty'}]) and return
    end
    unless change_password_params[:password_confirm].present?
      render_400_invalid_validation([{resource: 'User', field: 'password_confirm', code: 'empty'}]) and return
    end
    change_status = change_password_params[:password] == change_password_params[:password_confirm]
    unless change_status
      render_400_invalid_validation([{resource: 'User', field: 'password_confirm', code: 'confirmation'}]) and return
    end

    current_user = Entities::User.token_authenticate!(params[:token])
    if current_user.present? && DateTime.now <= current_user.token_expires_at
      current_user.password = change_password_params[:password]
      current_user.reset_token
      current_user.save!
      render json: {}, status: 200
    else
      render json: { errors: { code: '', message: "user not found or invalid token." } }, status: 422
    end
  end

  def at_url
    at_user_bank_account_ids = @current_user.try(:at_user).try(:at_user_bank_accounts).try(:pluck ,:id)
    at_user_card_account_ids = @current_user.try(:at_user).try(:at_user_card_accounts).try(:pluck ,:id)
    at_user_emoney_service_account_ids = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:pluck, :id)

    return render json: { errors: { code: '', message: "five account limit of free users" } }, status: 422  unless check_at_user_limit_of_free_account(at_user_bank_account_ids, at_user_card_account_ids, at_user_emoney_service_account_ids)

    @response = Services::AtUserService.new(@current_user).at_url
    render 'at_url', formats: 'json', handlers: 'jbuilder'
  end

  def at_sync
    # ATユーザーが作成されていなければスキップする
    return render json: {}, status: 200 unless @current_user.try(:at_user)

    if params[:only_accounts] == "true"
      Services::AtUserService::Sync.new(@current_user).sync_accounts
      return render json: {}, status: 200
    end

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
    at_user_bank_account_ids = @current_user.try(:at_user).try(:at_user_bank_accounts).try(:pluck ,:id)
    at_user_card_account_ids = @current_user.try(:at_user).try(:at_user_card_accounts).try(:pluck ,:id)
    at_user_emoney_service_account_ids = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:pluck, :id)

    return render_400_invalid_validation([{ "field": 'user_cancel_reason', "code": 'blank' }]) unless cancel_checklists.present?

    # 削除対象のテーブル
    # at_users, at_user_tokens, at_user_xxxx_accounts, users
    begin
      ActiveRecord::Base.transaction do
        begin
          # 口座アカウント削除 ATの共有している口座の削除 ペアリングの解除の処理を行う
          Services::ParingService.new(@current_user).cancel
          # ATの共有していない口座の削除
          delete_at_user_account(at_user_bank_account_ids, at_user_card_account_ids, at_user_emoney_service_account_ids)
          # ATのユーザーアカウント削除（退会）
          Services::AtUserService.new(@current_user).delete_user
        rescue AtAPIStandardError => at_err
          # TODO クラッシュレポートの仕組みを入れるアラートメールなどで通知する
          p at_err
        end

        begin
          # 退会理由を記載する
          register_cancel_reasons(cancel_checklists, cancel_reason)
          # 削除対象のテーブル
          # at_user_tokens at_users users
          if @user.try(:at_user).try(:token).present?
            @current_user.at_user.at_user_tokens.destroy_all
            @current_user.at_user.destroy
          end

          @current_user.delete
          @current_user = nil

        rescue => exception
          raise exception
        end
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
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

  def check_at_user_limit_of_free_account(at_user_bank_account_ids, at_user_card_account_ids, at_user_emoney_service_account_ids)
    number_of_account =  0
    if at_user_bank_account_ids.present?
      number_of_account += at_user_bank_account_ids.count
    end

    if at_user_card_account_ids.present?
      number_of_account += at_user_card_account_ids.count
    end

    if at_user_emoney_service_account_ids.present?
      number_of_account += at_user_emoney_service_account_ids.count
    end
    @current_user.free? && number_of_account < Settings.at_user_limit_free_account
  end

  def register_cancel_reasons(cancel_checklists, cancel_reason)
    Services::UserCancelAnswerService.new(@current_user).register_cancel_checklist(cancel_checklists)
    Services::UserCancelReasonService.new(@current_user).register_cancel_reason(cancel_reason) if cancel_reason.present?
  end

end
