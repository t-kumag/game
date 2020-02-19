class Services::WalletService

  def initialize(user, wallet)
    @user = user
    @wallet = wallet
  end

  def update_recalculate_initial_balance_and_balance(balance)
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
    params = {
        group_id: @user.group_id,
        share: param[:share],
        name: param[:name],
    }
    @wallet.update!(params)
  end

  def share?
    @wallet.share
  end

end
