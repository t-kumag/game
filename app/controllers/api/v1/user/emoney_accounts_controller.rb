class Api::V1::User::EmoneyAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user.try(:at_user).blank? || @current_user.try(:at_user).try(:at_user_emoney_service_accounts).blank?
        @responses = []
      else
        @responses = []
        @current_user.at_user.at_user_emoney_service_accounts.where(share: false).each do |a|
          @responses << {
            id: a.id,
            name: a.fnc_nm,
            amount: a.balance,
            fnc_id: a.fnc_id,
            last_rslt_cd: a.last_rslt_cd,
            last_rslt_msg: a.last_rslt_msg
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

    # TODO: user_distributed_transactionsを参照するようにする
    def summary
      share = false || params[:share]
      if @current_user.try(:at_user).blank? || @current_user.try(:at_user).try(:at_user_emoney_service_accounts).blank?
        @response = {
          amount: 0,
        }
      else
        amount = if share
                   # shareを含む場合
                   @current_user.at_user.at_user_emoney_service_accounts.sum{|i| i.current_month_payment}
                 else
                   @current_user.at_user.at_user_emoney_service_accounts.where(at_user_emoney_service_accounts: {share: false}).sum{|i| i.current_month_payment}
                 end
        @response = {
          amount: amount
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end

    def update
      account_id = params[:id].to_i
      if disallowed_at_emoney_ids?([account_id])
        render_disallowed_financier_ids && return
      end

      if @current_user.try(:at_user).try(:at_user_emoney_service_accounts).pluck(:id).include?(account_id)
        account = Entities::AtUserEmoneyServiceAccount.find account_id
        account.update!(get_account_params)
        if account.share
          options = create_activity_options("family")
          Services::ActivityService.create_activity(account.at_user.user_id, account.group_id,  DateTime.now, :person_account_to_family, options)
          Services::ActivityService.create_activity(account.at_user.user.partner_user.try(:id), account.group_id,  DateTime.now, :person_account_to_family_partner, options)
        end
        render json: {}, status: 200
      else
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

      render_disallowed_account_ids && return if disallowed_at_emoney_account_ids?([account_id])
      render_disallowed_financier_ids && return if disallowed_at_emoney_ids?([account_id])

      if @current_user.try(:at_user).try(:at_user_emoney_service_accounts).pluck(:id).include?(account_id)
        Services::AtUserService.new(@current_user).delete_account(Entities::AtUserEmoneyServiceAccount, [account_id])
      end
      render json: {}, status: 200
    end

    private
    def create_activity_options(account)
      options = {}
      options[:goal] = nil
      options[:transaction] = nil
      options[:transactions] = nil
      options[:account] = account
      options
    end

end
