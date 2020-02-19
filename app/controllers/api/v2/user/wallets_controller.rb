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
    if disallowed_wallet_ids?([wallet_id])
      render_disallowed_financier_ids && return
    end

    if @current_user.try(:wallets).pluck(:id).include?(wallet_id)
      require_group && return if params[:wallets][:share] == true
      wallet = Entities::Wallet.find wallet_id
      wallet.update!(update_params)
      if wallet.share
        options = create_activity_options(wallet, 'family')
        Services::ActivityService.create_activity(@current_user.id, @current_user.group_id,  DateTime.now, :person_wallet_to_family, options)
        Services::ActivityService.create_activity(@current_user.partner_user.id, @current_user.group_id,  DateTime.now, :person_wallet_to_family_partner, options)
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

  def update_params
    param = params.require(:wallets).permit(:name, :share)
    result = {
      group_id: @current_user.group_id,
      name: param[:name]
    }
    result[:share] = param[:share] if param.key?(:share)
    result
  end

  def create_params
    param = params.require(:wallets).permit(:name, :balance).merge(user_id: @current_user.id)
    param[:initial_balance] = param[:balance]
    param
  end

  def create_activity_options(wallet, account)
    options = {}
    options[:goal] = nil
    options[:transaction] = nil
    options[:transactions] = nil
    options[:wallet] = create_wallet(wallet, account)
    options
  end

  def create_wallet(w, account)
    wallet = {}
    wallet[:id] = w.id
    wallet[:account] = account
    wallet
  end
end
