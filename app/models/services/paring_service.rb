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
    bulk = []
    (others + [@user.id]).each do |user_id|
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
   
    
  end
end
