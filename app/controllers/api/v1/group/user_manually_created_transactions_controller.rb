class Api::V1::Group::UserManuallyCreatedTransactionsController < ApplicationController
  before_action :authenticate

  def index
    # create id list for group users
    group_user_ids = [@current_user.id]
    partner_user_id = @current_user.try(:partner_user).try(:id)
    group_user_ids += [partner_user_id] if partner_user_id.present?

    # pick shared transactions
    @transactions = Entities::UserManuallyCreatedTransaction.where(user_id: group_user_ids).joins(:user_distributed_transaction).where(user_distributed_transactions: {share: true}).all
    render :index, formats: :json, handlers: :jbuilder
  end
end
