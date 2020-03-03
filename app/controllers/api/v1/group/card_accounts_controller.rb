class Api::V1::Group::CardAccountsController < ApplicationController
    before_action :authenticate

    def index
      share_on_card_accounts = Services::AtCardTransactionService.new(@current_user).get_group_account()
      share_on_card_accounts = Services::FinanceService.new(@current_user).get_account(share_on_card_accounts)

      if share_on_card_accounts.blank?
        @responses = []
      else
        @responses = []
        share_on_card_accounts.each do |ca|
          name = ca.name.present? ? ca.name : ca.fnc_nm
          @responses << {
              id: ca.id,
              name: name,
              amount: ca.current_month_used_amount,
              fnc_id: ca.fnc_id,
              last_rslt_cd: ca.last_rslt_cd,
              last_rslt_msg: ca.last_rslt_msg
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
      share_on_card_accounts = Services::AtCardTransactionService.new(@current_user).get_group_account()
      if share_on_card_accounts.blank?
          @response = {
            amount: 0,
        }
      else
        @response = {
            amount: share_on_card_accounts.sum{|i| i.current_month_used_amount}
        }
      end

      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
