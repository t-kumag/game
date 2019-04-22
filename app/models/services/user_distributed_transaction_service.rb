class Services::UserDistributedTransactionService
  def initialize(user, transaction)
    @user = user
    @transaction = transaction
  end

  def create_user_manually_created
    distributed_transaction = Entities::UserDistributedTransaction.new
    save_user_manually_created(distributed_transaction)
  end

  def update_user_manually_created
    distributed_transaction = Entities::UserDistributedTransaction.find_or_initialize_by(
      user_manually_created_transaction_id: @transaction.id)
    save_user_manually_created(distributed_transaction)
  end

  def delete_user_manually_created
    Entities::UserDistributedTransaction.find(user_manually_created_transaction_id: @transaction.id).destroy
  end

  def save_user_manually_created(distributed_transaction)
    distributed_transaction.update_attributes(
      user_id: @transaction.user_id,
      group_id: @transaction.group_id,
      share: @transaction.share,
      used_date: @transaction.used_date,
      at_user_bank_transaction_id: nil,
      at_user_card_transaction_id: nil,
      at_user_emoney_transaction_id: nil,
      user_manually_created_transaction_id: @transaction.id
    )
  end
end
