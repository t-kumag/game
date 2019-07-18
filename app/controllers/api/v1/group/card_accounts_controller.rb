class Api::V1::Group::CardAccountsController < ApplicationController
    before_action :authenticate

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
              amount: 0
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

    # TODO 今月の引き落としを計算 shareされているもの
    def summary
      if @current_user.try(:at_user).try(:at_user_card_accounts).blank?
          @response = {
            amount: 0,
        }
      else
        share_on_card_accounts = Entities::AtUserCardAccount.where(group_id: @current_user.group_id).where(share: true)

        @response = {
            amount: share_on_card_accounts.sum{|i| i.current_month_payment}
        }
      end

      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
