class Services::PaymentMethodService
  def initialize(user)
    @user = user
  end

  def payment_methods
    wallets = []
    wallets << Entities::Wallet.where(user_id: @user.id, share: false)
    wallets << Entities::Wallet.where(group_id: @user.group_id, share: true)
    wallets.flatten!
    result = wallets.map do |w|
      next if w.blank?
      {
        id: w.id,
        type: 'wallet',
        name: w.name
      }
    end
    result
  end
end
