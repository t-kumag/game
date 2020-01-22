class Api::V2::Group::WalletsController < ApplicationController
  before_action :authenticate

  def index
    @responses = []
    Entities::Wallet.where(group_id: @current_user.group_id, share: true).each do |w|
      @responses << {
        id: w.id,
        name: w.name,
        amount: w.balance,
        # TODO: 目標は次回対応
        # goals: Services::GoalService.new(@current_user).goals(a.id)
      }
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def create
    Entities::Wallet.create!(create_params)
    render json: {}, status: :no_content
  end

  private

  def create_params
    param = params.require(:wallets).permit(:name, :balance).merge(user_id: @current_user.id, group_id: @current_user.group_id, share: true)
    param[:initial_balance] = param[:balance]
    param
  end
end
