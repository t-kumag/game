class Api::V1::Group::BsController < ApplicationController
  before_action :authenticate, :require_group

  def summary
    bank_amount = 0
    emoney_amount = 0
    share_off_goal_amount = 0
    share_on_goal_amount = 0

    share_off_bank_accounts = @current_user.try(:at_user).try(:at_user_bank_accounts).where(at_user_bank_accounts: {share: false})
    share_on_bank_accounts = Entities::AtUserBankAccount.where(group_id: @current_user.group_id).where(share: true)
    share_on_emoney_accounts = Entities::AtUserEmoneyServiceAccount.where(group_id: @current_user.group_id).where(share: true)

    if share_off_bank_accounts
      share_off_goal_amount = Services::GoalService.new(@current_user).goal_amount(share_off_bank_accounts.pluck(:id))
    end

    if share_on_bank_accounts
      bank_amount = share_on_bank_accounts.sum{|i| i.balance}
      share_on_goal_amount = Services::GoalService.new(@current_user).goal_amount(share_on_bank_accounts.pluck(:id))
    end

    if share_on_emoney_accounts
      emoney_amount = share_on_emoney_accounts.sum{|i| i.balance}
    end

    @response = {
        amount: bank_amount + emoney_amount + share_off_goal_amount - share_on_goal_amount
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end