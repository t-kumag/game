class Api::V1::User::CardAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user.try(:at_user).blank? || @current_user.try(:at_user).try(:at_user_card_accounts).blank?
        @responses = []
      else
        @responses = []

        @current_user.at_user.at_user_card_accounts.where(share: false).each do |ca|
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
      share = false || params[:share]
      if @current_user.try(:at_user).blank? || @current_user.try(:at_user).try(:at_user_card_accounts).blank?
        @response = {
          amount: 0,
        }
      else
        amount = if share
          # shareを含む場合
          # TODO: リリース後対応 各口座の今月の利用額の合算 → 今月の引落額の合算にする
          @current_user.at_user.at_user_card_accounts.sum{|i| i.current_month_used_amount}
        else
          # TODO: リリース後対応 各口座の今月の利用額の合算 → 今月の引落額の合算にする
          @current_user.at_user.at_user_card_accounts.where(share: false).sum{|i| i.current_month_used_amount}
        end
        @response = {
          amount: amount
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end

    def update
      account_id = params[:id].to_i
      if disallowed_at_card_ids?([account_id])
        render_disallowed_financier_ids && return
      end

      if @current_user.try(:at_user).try(:at_user_card_accounts).pluck(:id).include?(account_id)
        require_group && return if params[:share] == true
        account = Entities::AtUserCardAccount.find account_id
        account.update!(get_account_params)
        render json: {}, status: 200
      else
        # TODO(fujiura): code の検討と、エラー処理共通化
        render json: { errors: { code: '', mesasge: "account not found." } }, status: 200
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
      if disallowed_at_card_ids?([account_id])
        render_disallowed_financier_ids && return
      end

      if @current_user.try(:at_user).try(:at_user_card_accounts).pluck(:id).include?(account_id)
        Services::AtUserService.new(@current_user).delete_account(Entities::AtUserCardAccount, [account_id])
      end
      render json: {}, status: 200
    end
      
end
