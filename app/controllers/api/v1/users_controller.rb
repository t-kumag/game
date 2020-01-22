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

      Entities::UserProfile.new({
        user_id: @user.id,
        gender: nil,
        birthday: nil,
        has_child: 0
      }).save!
      
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
      render json: { errors: [ERROR_TYPE::NUMBER['001002']] }, status: 422
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
      render json: { errors: [ERROR_TYPE::NUMBER['001003']] }, status: 422
    end
  end

  def at_url
    finance = Services::FinanceService.new(@current_user).find_finance(:fnc_id, params[:fnc_id]) if params.has_key?(:fnc_id)
    skip_account_limit = check_finance_error(finance)

    # 無料ユーザーの口座数が上限に達していた場合はエラーを返し口座数を制限する
    # AT口座のエラー解消の場合は口座数の制限はスキップする
    if limit_of_registered_finance? == false && skip_account_limit == false
        return render json: { errors: [ERROR_TYPE::NUMBER['007002']] }, status: 422
    end

    @response = Services::AtUserService.new(@current_user).at_url
    render 'at_url', formats: 'json', handlers: 'jbuilder'
  end

  def at_sync
    begin
      # ATユーザーが作成されていなければスキップする
      return render json: {}, status: 200 unless @current_user.try(:at_user)

      if params[:only_accounts] == "true"
        Services::AtUserService::Sync.new(@current_user, params[:fnc_type]).sync_accounts
        return render json: {}, status: 200
      end

      at_user_service = Services::AtUserService.new(@current_user, params[:fnc_type])
      # TODO ATのAPI一本化の対応
      # 口座登録が正常に行われているものはスクレイピング必要ないためコメント
      # リアルタイムで明細を取得したい場合に必要となるため、のちの課金対応で修正する
      # http://redmine.369webcash.com/issues/2916
      # at_user_service.exec_scraping

      at_user_service.sync_at_user_finance
      at_user_service.sync_user_distributed_transaction
    rescue => e
      SlackNotifier.ping("ERROR Api::V1::UsersController#at_sync")
      Rails.logger.error("ERROR Api::V1::UsersController#at_sync")
      SlackNotifier.ping(e)
      Rails.logger.error(e)
    end

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
    at_user_bank_account_ids = @current_user.try(:at_user).try(:at_user_bank_accounts).try(:where, share: false).try(:pluck ,:id)
    at_user_card_account_ids = @current_user.try(:at_user).try(:at_user_card_accounts).try(:where, share: false).try(:pluck ,:id)
    at_user_emoney_service_account_ids = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:where, share: false).try(:pluck, :id)

    # @TODO 2019/09 時点の仕様で退会理由のテキストフォームのみとなり
    # 将来はチェックボックスになる予定のため処理は残す
    # return render_400_invalid_validation([{ "field": 'user_cancel_reason', "code": 'blank' }]) unless cancel_checklists.present?
    return render_400_invalid_validation([{ "field": 'user_cancel_reason', "code": 'blank' }]) unless cancel_reason.present?

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
          if @current_user.try(:at_user).try(:token).present?
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

  def redirect_top
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

  def register_cancel_reasons(cancel_checklists, cancel_reason)
    # @TODO 2019/09 時点の仕様で退会理由のテキストフォームのみとなり
    # 将来はチェックボックスになる予定のため処理は残す
    # Services::UserCancelAnswerService.new(@current_user).register_cancel_checklist(cancel_checklists)
    Services::UserCancelReasonService.new(@current_user).register_cancel_reason(cancel_reason)
  end

  # AT口座エラーの有無を確認する
  def check_finance_error(finance)
    return false unless finance.present?
    if finance.last_rslt_cd === 'E' || finance.last_rslt_cd === 'A'
      return true
    end
    false
  end

end
