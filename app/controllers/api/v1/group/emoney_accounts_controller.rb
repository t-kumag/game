class Api::V1::Group::EmoneyAccountsController < ApplicationController
    before_action :authenticate

    def index
      share_on_emoney_service_accounts = Services::AtEmoneyTransactionService.new(@current_user).get_group_account()
      share_on_emoney_service_accounts = Services::FinanceService.new(@current_user).get_account(share_on_emoney_service_accounts)

      if share_on_emoney_service_accounts.blank?
        @responses = []
      else
        @responses = []
        share_on_emoney_service_accounts.each do |a|
          name = a.name.present? ? a.name : a.fnc_nm
          @responses << {
              id: a.id,
              name: name,
              amount: a.balance,
              fnc_id: a.fnc_id,
              last_rslt_cd: a.last_rslt_cd,
              last_rslt_msg: a.last_rslt_msg
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

    # TODO: user_distributed_transactionsを参照するようにする
    def summary
      share_on_emoney_service_accounts = Services::AtEmoneyTransactionService.new(@current_user).get_group_account()
      if share_on_emoney_service_accounts.blank?
        @response = {
            amount: 0,
        }
      else
        @response = {
            amount: share_on_emoney_service_accounts.sum{|i| i.current_month_payment(share_on_emoney_service_accounts.pluck(:at_user_id))}
        }
      end

      render 'summary', formats: 'json', handlers: 'jbuilder'
    end

end
