class Services::ParingService
  def initialize(user)
    @user = user
  end

  def cancel
    # カレントユーザが所属するグループをすべて抽出
    groups = Entities::ParticipateGroup.where(user_id: @user.id).pluck(:group_id)
    # 同グループに所属するユーザをすべて抽出
    others = Entities::ParticipateGroup.where(group_id: groups).where.not(user_id: @user.id).pluck(:user_id)

    # 自分含め同グループの UserDistributedTransaction の share フラグを false へ
    all_user_ids = others + [@user.id]
    bulk = []
    Entities::UserDistributedTransaction.where(user_id: all_user_ids, share: true).each do |transaction|
      transaction.group_id = nil
      transaction.share = false
      bulk << transaction
    end

    Entities::UserDistributedTransaction.import bulk, on_duplicate_key_update: [:share]

    # グループに紐づく目標を削除
    Entities::Goal.where(group_id: groups).destroy_all

    # グループに所属するユーザーの共有口座削除
    all_user_ids.each do |user_id|
      user = Entities::User.find_by(id: user_id)
      at_user_bank_account_ids = user.try(:at_user).try(:at_user_bank_accounts).where(share: true).pluck(:id)
      at_user_card_account_ids = user.try(:at_user).try(:at_user_card_accounts).where(share: true).pluck(:id)
      at_user_emoney_service_account_ids = user.try(:at_user).try(:at_user_emoney_service_accounts).where(share: true).pluck(:id)

      if at_user_bank_account_ids.present?
        Services::AtUserService.new(user).delete_account(Entities::AtUserBankAccount, at_user_bank_account_ids)
      end

      if at_user_card_account_ids.present?
        Services::AtUserService.new(user).delete_account(Entities::AtUserCardAccount, at_user_card_account_ids)
      end

      if at_user_emoney_service_account_ids.present?
        Services::AtUserService.new(user).delete_account(Entities::AtUserEmoneyServiceAccount, at_user_emoney_service_account_ids)
      end

    end

    # グループに紐づく中間テーブルを削除
    Entities::ParticipateGroup.where(group_id: groups).destroy_all
  end
end
