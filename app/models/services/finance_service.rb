# 各金融のモデルが特定できない場合に利用する
# モデルが特定できる場合はEntities::Financeを参照する
# サンプルケース：fnc_idは特定できるが対象のモデルが特定できない場合
class Services::FinanceService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def find_finance(key, val)
    f = Entities::AtUserBankAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
    f = Entities::AtUserCardAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
    f = Entities::AtUserEmoneyServiceAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
  end
end
