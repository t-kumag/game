class Api::V2::Group::WalletsController < ApplicationController
  before_action :authenticate

  def index
    @responses = []
    Entities::Wallet.where(group_id: @current_user.group_id, share: true).each do |w|
      @responses << {
        id: w.id,
        name: w.name,
        amount: w.balance,
        goals: Services::GoalService.new(@current_user).goals(w, true)
      }
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def create
    unless limit_of_registered_finance?
      return render json: { errors: { code: '007002', message: 'five account limit of free users' } }, status: 422
    end
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
