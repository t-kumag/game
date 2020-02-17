class Services::WalletService

  def initialize(user, wallet)
    @user = user
    @wallet = wallet
  end

  def recalculate_initial_balance_and_balance(balance)
    balance = balance.present? ? balance : @wallet.balance
    initial_balance = @wallet.initial_balance

    if balance.present?
      balance_difference = balance - @wallet.balance
      expense = @wallet.initial_balance -  @wallet.balance

      initial_balance += balance_difference
      balance = initial_balance - expense
    end

    result = {
        initial_balance: initial_balance,
        balance: balance
    }

    result
  end

  def update_wallet(recalculate, param)
    save_params = get_wallet_params(recalculate, param)
    save_params[:share] = param[:share] if param.key?(:share)
    @wallet.update!(save_params)
  end

  def share?
    @wallet.share
  end

  private
  def get_wallet_params(recalculate, param)
    {
        group_id: @user.group_id,
        name: param[:name],
        initial_balance: recalculate[:initial_balance],
        balance: recalculate[:balance]
    }
  end
end
