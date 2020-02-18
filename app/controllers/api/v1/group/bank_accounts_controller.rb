class Api::V1::Group::BankAccountsController < ApplicationController
  before_action :authenticate, :require_group

  def index
    share_on_bank_accounts = Entities::AtUserBankAccount.where(group_id: @current_user.group_id).where(share: true)
    if share_on_bank_accounts.blank?
      @responses = []
    else
      @responses = []

      share_on_bank_accounts.each do |a|
        @responses << {
            id: a.id,
            name: a.fnc_nm,
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
    if share_on_bank_accounts.blank?
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

