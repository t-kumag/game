class Api::V1::Group::BsController < ApplicationController
  before_action :authenticate

  # TODO groupとして取得するデータの仕様を決める必要がある
  # TODO いまは口座のbalanceだけ足している。目標金額など他の項目も足す 20190513
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

end
