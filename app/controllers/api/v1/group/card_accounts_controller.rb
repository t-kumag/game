class Api::V1::Group::CardAccountsController < ApplicationController
    before_action :authenticate

    def index
      share = false || params[:share]
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_card_accounts.blank?
        @responses = []
      else
        @responses = []

        accounts = if share
                     @current_user.at_user.at_user_card_accounts
                   else
                     @current_user.at_user.at_user_card_accounts.where(at_user_card_accounts: {share: false})
                   end

        accounts.each do |ca|
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
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_card_accounts.blank?
        @response = {
            amount: 0,
        }
      else
        amount = 0
        group_id = @current_user.group_id

        unless group_id.nil?
          pair_user = Services::AtUserCardAccountsService.get_balance_summary(group_id)
          amount = pair_user.sum{|i| i.current_month_payment(group_id) }
        end

        @response = {
            amount: amount
        }

      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
