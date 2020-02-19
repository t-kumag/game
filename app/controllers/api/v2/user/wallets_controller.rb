class Api::V2::User::WalletsController < ApplicationController
  before_action :authenticate

  def index
    @responses = []
    Entities::Wallet.where(user_id: @current_user.id, share: false).each do |w|
      @responses << {
        id: w.id,
        name: w.name,
        amount: w.balance,
        goals: Services::GoalService.new(@current_user).goals(w)
      }
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def create
    Entities::Wallet.create!(create_params)
    render json: {}, status: :no_content
  end

  def update
    wallet_id = params[:id].to_i
    wallet_service = Services::WalletService.new(@current_user, Entities::Wallet.find(wallet_id))

    param = params.require(:wallets).permit(:name, :share, :balance)
    render_disallowed_financier_ids && return if disallowed_wallet_ids?([wallet_id])

    if @current_user.try(:wallets).pluck(:id).include?(wallet_id)
      require_group && return if  param[:share] == true

      wallet_service.update_recalculate_initial_balance_and_balance(param[:balance])
      wallet_service.update_name_and_share_and_group_id(param)
      if wallet_service.share?
        # TODO: アクティビティ修正
        # Services::ActivityService.create_activity(account.at_user.user_id, account.group_id,  DateTime.now, :person_account_to_family)
        # Services::ActivityService.create_activity(account.at_user.user.partner_user.id, account.group_id,  DateTime.now, :person_account_to_family_partner)
      end
      render json: {}, status: :no_content
    else
      render json: { errors: { code: '', mesasge: 'wallet not found.' } }, status: 422
    end
  end

  def destroy
    wallet_id = params[:id].to_i
    if disallowed_wallet_ids?([wallet_id])
      render_disallowed_financier_ids && return
    end
    
    if @current_user.try(:wallets).pluck(:id).include?(wallet_id)
      Entities::Wallet.find(wallet_id).destroy
    end
    render json: {}, status: :no_content
  end

  private
  def create_params
    param = params.require(:wallets).permit(:name, :balance).merge(user_id: @current_user.id)
    param[:initial_balance] = param[:balance]
    param
  end
end
