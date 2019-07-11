# TODO(fujiura) group で取得する明細の情報を明確にする
class Api::V1::Group::CardTransactionsController < ApplicationController
  before_action :authenticate

  def index
    partner_user_id = Entities::ParticipateGroup.where(group_id: @current_user.group_id).where.not(user_id: @current_user.id).pluck(:user_id).first
    partner_user = Entities::User.find(partner_user_id)
    @transactions = Services::AtCardTransactionService.new(partner_user).list(params[:card_account_id], params[:page])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    partner_user_id = Entities::ParticipateGroup.where(group_id: @current_user.group_id).where.not(user_id: @current_user.id).pluck(:user_id).first
    partner_user = Entities::User.find(partner_user_id)
    @response = Services::AtCardTransactionService.new(partner_user).detail(params[:card_account_id], params[:id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    partner_user_id = Entities::ParticipateGroup.where(group_id: @current_user.group_id).where.not(user_id: @current_user.id).pluck(:user_id).first
    partner_user = Entities::User.find(partner_user_id)
    @response = Services::AtCardTransactionService.new(partner_user).update(
        params[:id],
        params[:at_transaction_category_id],
        params[:used_location],
        params[:is_shared],
        params[:is_shared] ? @current_user.group_id : nil
    )

    # TODO(fujiura): 何を返すべき？
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
