class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: [:at_url, :at_sync, :at_token, :destroy]
  before_action :check_temporary_user, only: [:create]

  def create
    @user = Entities::User.new
    @user.email = sign_up_params[:email]
    @user.password = sign_up_params[:password]
    @user.email_authenticated = false
    @user.reset_token
    @user.save!
    MailDelivery.user_registration(@user).deliver

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

  def at_url
    @response = Services::AtUserService.new(@current_user).at_url
    render 'at_url', formats: 'json', handlers: 'jbuilder'
  end

  def at_sync
    at_user_service = Services::AtUserService.new(@current_user, params[:target])
    at_user_service.exec_scraping
    at_user_service.sync

    # TODO: 仮り実装 user_distributed_transactionsに同期
    # TODO 手動振り分けの同期が未対応
    puts 'user_distributed_transactions sync=========='
    Services::UserDistributedTransactionService.new(@current_user, params[:target]).sync

    obj = {}
    render json: obj, status: 200
  end

  def at_token
    @response = Services::AtUserService.new(@current_user).token
    render 'at_token', formats: 'json', handlers: 'jbuilder'
  end

  def destroy

    cancel_reason = delete_user_params[:user_cancel_reason]
    cancel_checklists = delete_user_params[:cancel_checklists]

    # TODO: バリデーション
    # TODO 例外処理と共通化
    begin
      if cancel_checklists.present?
        Services::UserCancelAnswerService.new(@current_user).register_cancel_checklist(cancel_checklists)
        Services::UserCancelReasonService.new(@current_user).register_cancel_reason(cancel_reason) if cancel_reason.present?
        Services::ParingService.new(@current_user).cancel
        Entities::User.find(@current_user.id).delete
        @current_user.clear_token
        @current_user = nil
      else
        render json: {}, status: :bad_request
      end
    rescue ActiveRecord::RecordInvalid => db_err
      p db_err
      render(json: {}, status: 400) && return
    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end

    render json: {}, status: 200

  end

  private
  def sign_up_params
    params.permit(:email, :password)
  end

  def delete_user_params
    params.permit(:user_cancel_reason, cancel_checklists: [])
  end

end
