class Services::WalletService

  def initialize(user, wallet)
    @user = user
    @wallet = wallet
  end

  def update_initial_balance_and_balance(balance)
    return false unless balance.present?
    return false if balance == @wallet.balance
    initial_balance = @wallet.initial_balance
    balance_difference = balance - @wallet.balance
    expense = @wallet.initial_balance - @wallet.balance

    initial_balance += balance_difference
    balance = initial_balance - expense

    params = {
        initial_balance: initial_balance,
        balance: balance
    }

    @wallet.update!(params)
  end

  def update_name_and_share_and_group_id(param)
    name = param[:name].present? ? param[:name] : @wallet.name
    before_share = @wallet.share
    after_share = param[:share]
    params = {
        group_id: @user.group_id,
        share: param[:share],
        name: name,
    }
    @wallet.update!(params)

    if before_share != after_share
      user_manually_created_transactions = Entities::UserManuallyCreatedTransaction.where(payment_method_type: "wallet", payment_method_id: @wallet.id)
      user_manually_created_transactions.update_all(share: after_share)
      Entities::UserDistributedTransaction.where(user_manually_created_transaction_id: user_manually_created_transactions.pluck(:id)).update_all(share: after_share)
    end
  end

  def share?
    @wallet.share
  end

  def get_wallet
    @wallet
  end

end
