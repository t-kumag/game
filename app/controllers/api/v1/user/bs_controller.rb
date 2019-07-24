class Api::V1::User::BsController < ApplicationController
  before_action :authenticate

  def summary
    amount = 0
    goal_amount = 0

    at_bank_accounts = @current_user.try(:at_user).try(:at_user_bank_accounts).where(at_user_bank_accounts: {share: false})
    if at_bank_accounts
      amount = at_bank_accounts.sum{|i| i.balance}
      goal_amount = Services::GoalService.new(@current_user).goal_amount(at_bank_accounts.pluck(:id))
    end
    @response = {
        amount: amount - goal_amount
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end
