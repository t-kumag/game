class Api::V2::Group::CardAccountsController < ApplicationController
    before_action :authenticate, :require_group

    def index
      share_on_card_accounts = Entities::AtUserCardAccount.where(group_id: @current_user.group_id).where(share: true)
      if share_on_card_accounts.blank?
        @responses = []
      else
        @responses = []
        share_on_card_accounts.each do |ca|
          @responses << {
              id: ca.id,
              name: ca.fnc_nm,
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
      share_on_card_accounts = Entities::AtUserCardAccount.where(group_id: @current_user.group_id).where(share: true)
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
