class Api::V1::Group::BankAccountsController < ApplicationController
  before_action :authenticate

  def index
    share_on_bank_accounts = Entities::AtUserBankAccount.where(group_id: @current_user.group_id).where(share: true)

    unless is_group?
      share_on_bank_accounts = Services::FinanceService.new(@current_user).get_account(share_on_bank_accounts)
    end

    if share_on_bank_accounts.blank?
      @responses = []
    else
      @responses = []

      share_on_bank_accounts.each do |a|
        name = a.name.present? ? a.name : a.fnc_nm
        @responses << {
            id: a.id,
            name: name,
            amount: a.balance,
            fnc_id: a.fnc_id,
            last_rslt_cd: a.last_rslt_cd,
            last_rslt_msg: a.last_rslt_msg,
            goals: Services::GoalService.new(@current_user).goals(a, true)
        }
      end
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  # TODO: user_distributed_transactionsを参照するようにする
  def summary
    share_on_bank_accounts = Entities::AtUserBankAccount.where(group_id: @current_user.group_id).where(share: true)
    if share_on_bank_accounts.blank? || is_group? === false
      @response = {
          amount: 0,
      }
    else
      @response = {
          amount: share_on_bank_accounts.sum{|i| i.balance}
      }
    end
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end
end

