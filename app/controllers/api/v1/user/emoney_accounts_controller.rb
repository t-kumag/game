class Api::V1::User::EmoneyAccountsController < ApplicationController
    before_action :authenticate

    # TODO 口座登録後に登録するものがあるか確認
    # TODO 現状はsync処理のみ

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
      share = false || params[:share]
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_emoney_service_accounts.blank?
        @response = {
          amount: 0,
        }
      else
        amount = if share
                   # shareを含む場合
                   @current_user.at_user.at_user_emoney_service_accounts.sum{|i| i.current_month_payment}


                 else
                   @current_user.at_user.at_user_emoney_service_accounts.where(at_user_card_accounts: {share: false}).sum{|i| i.current_month_payment}
                 end
        @response = {
          amount: amount
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end

    def destroy
      account_id = params[:id].to_i
      if @current_user.try(:at_user).try(:at_user_emoney_service_accounts).pluck(:id).include?(account_id)
        Services::AtUserService.new(@current_user).delete_account(Entities::AtUserEmoneyServiceAccount, account_id)
      end
      render json: {}, status: 200
    end

end
