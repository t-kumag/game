class Api::V1::Group::CardAccountsController < ApplicationController
    before_action :authenticate, :require_group

    def index
      if @current_user.try(:at_user).try(:at_user_card_accounts).blank?
        @responses = []
      else
        @responses = []

        share_on_card_accounts =
            Entities::AtUserCardAccount.where(group_id: @current_user.group_id).where(share: true)
        share_on_card_accounts.each do |ca|
          @responses << {
              id: ca.id,
              name: ca.fnc_nm,
              amount: 0,
              fnc_id: ca.fnc_id,
              last_rslt_cd: ca.last_rslt_cd,
              last_rslt_msg: ca.last_rslt_msg
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

    # TODO: user_distributed_transactionsを参照するようにする
    def summary
      if @current_user.try(:at_user).try(:at_user_card_accounts).blank?
          @response = {
            amount: 0,
        }
      else
        share_on_card_accounts = Entities::AtUserCardAccount.where(group_id: @current_user.group_id).where(share: true)

        @response = {
            amount: share_on_card_accounts.sum{|i| i.current_month_payment(share_on_card_accounts.pluck(:at_user_id))}
        }
      end

      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
