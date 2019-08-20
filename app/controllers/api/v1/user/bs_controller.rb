class Api::V1::User::BsController < ApplicationController
  before_action :authenticate

  def summary
    bank_amount = 0
    emoney_amount = 0
    goal_amount = 0

    # TODO: 一時的な対応 tryの不要な処理を削除する
    if @current_user.try(:at_user).try(:at_user_bank_accounts)
      at_bank_accounts = @current_user.try(:at_user).try(:at_user_bank_accounts).where(at_user_bank_accounts: {share: false})
    end
    if @current_user.try(:at_user).try(:at_user_emoney_service_accounts)
      at_emoney_accounts = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).where(at_user_emoney_service_accounts: {share: false})
    end

    if at_bank_accounts
      bank_amount = at_bank_accounts.sum{|i| i.balance}
      goal_amount = Services::GoalService.new(@current_user).goal_amount(at_bank_accounts.pluck(:id))
    end
    
    if at_emoney_accounts
      emoney_amount = at_emoney_accounts.sum{|i| i.balance}
    end

    @response = {
        amount: bank_amount + emoney_amount
        # TODO: 目標一覧を口座取引に表示するまで目標金額はBSに含めない
        #amount: bank_amount + emoney_amount - goal_amount
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end
