class Api::V1::Group::EmoneyAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_emoney_service_accounts.blank?
        @responses = []
      else
        @responses = []
        @current_user.at_user.at_user_emoney_service_accounts.each do |a|
          @responses << {
              id: a.id,
              name: a.fnc_nm,
              amount: a.balance
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
      # TODO: 家族の引き落とし総額について確認する。そもそも必要なのかどうかも含めて。
      # TODO: 実装は/user/emoney-accounts-summaryとほぼ同じになる予定
      # TODO: group_idが考慮されていない

      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_emoney_service_accounts.blank?
        @response = {
            amount: 0,
        }
      else
        amount = 0
        group_id = @current_user.group_id

        unless group_id.nil?
          pair_user = Services::AtUserEmoneyServiceAccountsService.get_balance_summary(group_id)
          amount = pair_user.sum{|i| i.current_month_payment(group_id) }
        end

        @response = {
            amount: amount
        }
      end

      render 'summary', formats: 'json', handlers: 'jbuilder'
    end

end
