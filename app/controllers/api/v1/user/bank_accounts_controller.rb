class Api::V1::User::BankAccountsController < ApplicationController
  before_action :authenticate

  # TODO 口座登録後に登録するものがあるか確認
  # TODO 現状はsync処理のみ

  def index
    share = false || params[:share]
    if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_bank_accounts.blank?
      @responses = []
    else
      @responses = []

      @current_user.at_user.at_user_bank_accounts.each do |a|
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
    if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_bank_accounts.blank?
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

  def destroy
    at_user_bank_account_id = params[:id].to_i
    if @current_user.try(:at_user).try(:at_user_bank_accounts).pluck(:id).include?(at_user_bank_account_id)
      Services::AtUserService.new(@current_user).delete_account(Entities::AtUserBankAccount, at_user_bank_account_id)
      Entities::AtUserBankAccount.find(params[:id]).destroy
    end
    render json: {}, status: 200
  end

end

