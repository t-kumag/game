class Api::V1::Group::EmoneyAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user.try(:at_user).try(:at_user_emoney_service_accounts).blank?
        @responses = []
      else
        @responses = []

        share_on_emoney_service_accounts =
            Entities::AtUserEmoneyServiceAccount.where(group_id: @current_user.group_id).where(share: true)

        share_on_emoney_service_accounts.each do |a|
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

      if @current_user.try(:at_user).try(:at_user_emoney_service_accounts).blank?
        @response = {
            amount: 0,
        }
      else
        share_on_emoney_service_accounts =
            Entities::AtUserEmoneyServiceAccount.where(group_id: @current_user.group_id).where(share: true)

        @response = {
            amount: share_on_emoney_service_accounts.sum{|i| i.current_month_payment(share_on_emoney_service_accounts.pluck(:at_user_id))}
        }
      end

      render 'summary', formats: 'json', handlers: 'jbuilder'
    end

end
