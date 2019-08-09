class Api::V1::User::BsController < ApplicationController
  before_action :authenticate

  def summary
    bank_amount = 0
    emoney_amount = 0
    goal_amount = 0

    at_bank_accounts = @current_user.try(:at_user).try(:at_user_bank_accounts).where(at_user_bank_accounts: {share: false})
    at_emoney_accounts = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).where(at_user_emoney_service_accounts: {share: false})
    
    if at_bank_accounts
      bank_amount = at_bank_accounts.sum{|i| i.balance}
      goal_amount = Services::GoalService.new(@current_user).goal_amount(at_bank_accounts.pluck(:id))
    end
    
    if at_emoney_accounts
      emoney_amount = at_emoney_accounts.sum{|i| i.balance}
    end

    @response = {
        amount: bank_amount + emoney_amount - goal_amount
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end
