class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: [:at_url, :at_sync, :at_token]
  def sign_up_params
    params.permit(:email, :password)
  end

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
end
