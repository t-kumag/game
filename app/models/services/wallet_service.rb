class Services::WalletService

  def initialize(user)
    @user = user
  end

  def recalculate(wallet, param)
    balance = param[:balance].present? ? param[:balance] : wallet.balance
    initial_balance = wallet.initial_balance

    if param[:balance].present?
      balance_difference = param[:balance] - wallet.balance
      expense = wallet.initial_balance -  wallet.balance

      initial_balance += balance_difference
      balance = initial_balance - expense
    end

    result = {
        initial_balance: initial_balance,
        balance: balance
    }

    result
  end

  def update_wallet(recalculate, param, wallet)
    result = {
        group_id: @user.group_id,
        name: param[:name],
        initial_balance: recalculate[:initial_balance],
        balance: recalculate[:balance]
    }

    result[:share] = param[:share] if param.key?(:share)
    wallet.update!(result)
  end
end
