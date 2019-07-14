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
            amount: a.balance,
            fnc_id: a.fnc_id
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_emoney_service_accounts.blank?
        @response = {
          amount: 0,
        }
      else
        amount = 0
        group_id = @current_user.at_user.at_user_emoney_service_accounts.pluck(:group_id).pop

        unless group_id.nil?
          pair_user = Services::AtUserEmoneyServiceAccountsService.get_balance_summary(group_id)
          amount = pair_user.sum{|i| i.current_month_payment }
        end

        @response = {
          amount: amount
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end

    def update
      account_id = params[:id].to_i
      if @current_user.try(:at_user).try(:at_user_emoney_service_accounts).pluck(:id).include?(account_id)
        account = Entities::AtUserEmoneyServiceAccount.find account_id
        account.update!(get_account_params)
        render json: {}, status: 200
      else
        # TODO(fujiura): code の検討と、エラー処理共通化
        render json: {errors: [{code: "message sample fobidden"}]}, status: 200
      end
    end

    def get_account_params
      {
        group_id: @current_user.group_id,
        share: params[:share],
      }
    end

    def destroy
      account_id = params[:id].to_i
      if @current_user.try(:at_user).try(:at_user_emoney_service_accounts).pluck(:id).include?(account_id)
        Services::AtUserService.new(@current_user).delete_account(Entities::AtUserEmoneyServiceAccount, account_id)
      end
      render json: {}, status: 200
    end

end
