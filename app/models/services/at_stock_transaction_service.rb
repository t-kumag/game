class Services::AtStockTransactionService

  def initialize(user, is_group=false)
    @user = user
    @is_group = is_group
  end


  def get_group_account()
    Entities::AtUserStockAccount
        .where(group_id: @user.group_id)
        .where(at_user_id: [@user.try(:at_user).try(:id), @user.partner_user.try(:at_user).try(:id)])
        .where(share: true)
  end

end
