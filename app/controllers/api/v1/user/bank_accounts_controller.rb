class Api::V1::User::BankAccountsController < ApplicationController
  before_action :authenticate

  def index
    if @current_user.try(:at_user).blank? || @current_user.try(:at_user).try(:at_user_bank_accounts).blank?
      @responses = []
    else
      @responses = []

      @current_user.at_user.at_user_bank_accounts.where(share: false).each do |a|
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
    if @current_user.try(:at_user).blank? || @current_user.try(:at_user).try(:at_user_bank_accounts).blank?
      @response = {
        amount: 0,
      }
    else
      amount = if share
        # shareを含む場合
        @current_user.at_user.at_user_bank_accounts.sum{|i| i.balance}
      else
        @current_user.at_user.at_user_bank_accounts.where(at_user_bank_accounts: {share: false}).sum{|i| i.balance}
      end
      @response = {
        amount: amount
      }
    end
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def update
    account_id = params[:id].to_i
    if disallowed_at_bank_ids?([account_id])
      render_disallowed_financier_ids && return
    end

    if @current_user.try(:at_user).try(:at_user_bank_accounts).pluck(:id).include?(account_id)
      require_group && return if params[:share] == true
      account = Entities::AtUserBankAccount.find account_id
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
    if disallowed_at_bank_ids?([account_id])
      render_disallowed_financier_ids && return
    end

    if @current_user.try(:at_user).try(:at_user_bank_accounts).pluck(:id).include?(account_id)
      Services::AtUserService.new(@current_user).delete_account(Entities::AtUserBankAccount, [account_id])
    end
    render json: {}, status: 200
  end
end

