class Services::ParingService
  def initialize(user)
    @user = user
  end

  def cancel()
    # カレントユーザが所属するグループをすべて抽出
    groups = Entities::ParticipateGroup.where(user_id: @user.id).pluck(:group_id)
    # 同グループに所属するユーザをすべて抽出
    others = Entities::ParticipateGroup.where(group_id: groups).where.not(user_id: @user.id).pluck(:user_id)
    
    # 自分含め同グループの UserDistributedTransaction の share フラグを false へ
    all_user_ids = others + [@user.id]
    bulk = []
    all_user_ids.each do |user_id|
      bulk += Entities::UserDistributedTransaction.where(user_id: user_id, share: true).map do |transaction|
        {
          id: transaction.id,
          used_date: transaction.used_date,
          share: false
        }
      end
    end
    Entities::UserDistributedTransaction.import [:id, :share, :used_date], 
                                                bulk, 
                                                on_duplicate_key_update: [:id, :share]
   
    # グループに紐づく目標を削除
    Entities::Goal.where(group_id: groups).destroy_all

    # グループに所属するユーザーの共有口座削除
    all_user_ids.each do |user_id|
      user = Entities::User.find_by(id: user_id)
      Rails.logger.debug user
      user&.at_user&.at_user_bank_accounts&.where(share: true)&.pluck(:id)&.each do |account_id|
        Services::AtUserService.new(user).delete_account(Entities::AtUserBankAccount, account_id)
      end
      user&.at_user&.at_user_card_accounts&.where(share: true)&.pluck(:id)&.each do |account_id|
        Services::AtUserService.new(user).delete_account(Entities::AtUserCardAccount, account_id)
      end
      user&.at_user&.at_user_emoney_service_accounts&.where(share: true)&.pluck(:id)&.each do |account_id|
        Services::AtUserService.new(user).delete_account(Entities::AtUserEmoneyServiceAccount, account_id)
      end
    end

    # グループに紐づく中間テーブルを削除
    Entities::ParticipateGroup.where(group_id: groups).destroy_all
    
  end
end
