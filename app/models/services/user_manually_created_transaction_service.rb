class Services::UserManuallyCreatedTransactionService
  def initialize(user, transaction)
    @user = user
    @transaction = transaction
  end

  def create_user_manually_created(options)
    Entities::UserDistributedTransaction.create!(
        user_id: @transaction.user_id,
        used_date: @transaction.used_date,
        group_id: options.has_key?(:group_id) ? options[:group_id] : nil,
        share: options.has_key?(:share) ? options[:share] : false,
        at_user_bank_transaction_id: nil,
        at_user_card_transaction_id: nil,
        at_user_emoney_transaction_id: nil,
        user_manually_created_transaction_id: @transaction.id,
        used_location: @transaction.used_location,
        amount: @transaction.amount,
        at_transaction_category_id:  @transaction.at_transaction_category_id
    )
  end

  def update_user_manually_created(options)
    Entities::UserDistributedTransaction.update!(
        user_id: @transaction.user_id,
        used_date: @transaction.used_date,
        group_id: options.has_key?(:group_id) ? options[:group_id] : nil,
        share: options.has_key?(:share) ? options[:share] : false,
        at_user_bank_transaction_id: nil,
        at_user_card_transaction_id: nil,
        at_user_emoney_transaction_id: nil,
        user_manually_created_transaction_id: @transaction.id,
        used_location: @transaction.used_location,
        amount: @transaction.amount,
        at_transaction_category_id:  @transaction.at_transaction_category_id
    )
  end

  def delete_user_manually_created
    Entities::UserDistributedTransaction.find(user_manually_created_transaction_id: @transaction.id).destroy
  end

end
