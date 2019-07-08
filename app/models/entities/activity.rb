class Entities::Activity < ApplicationRecord

  #個人支出(銀行)
  def self.add_bank_outcome_individual(date, user_id, count = 1)
    self.new(
        user_id: user_id,
        date: date,
        count: count,
        activity_type: :individual_bank_outcome,
    ).save!
  end

  #個人支出(カード)
  def self.add_card_outcome_individual(date, user_id, count = 1)
    self.new.transaction do
      self.new(
          user_id: user_id,
          date: date,
          count: count,
          activity_type: :individual_card_outcome,
      ).save!
    end
  end

  #個人支出(電子マネー)
  def self.add_emoney_outcome_individual(date, user_id, count = 1)
    self.new.transaction do
      self.new(
          user_id: user_id,
          date: date,
          count: count,
          activity_type: :individual_emoney_outcome,
      ).save!
    end
  end

  #夫婦支出(銀行)
  def self.add_bank_outcome_partner(date, user_id, group_id, count = 1)
    self.new.transaction do
      self.new(
          user_id: user_id,
          group_id: group_id,
          date: date,
          count: count,
          activity_type: :partner_bank_outcome,
      ).save!
    end
  end

  #夫婦支出(カード)
  def self.add_card_outcome_partner(date, user_id, group_id, count = 1)
    self.new.transaction do
      self.new(
          user_id: user_id,
          group_id: group_id,
          date: date,
          count: count,
          activity_type: :partner_card_outcome,
      ).save!
    end
  end

  #夫婦支出(電子マネー)
  def self.add_emoney_outcome_partner(date, user_id, group_id, count = 1)
    self.new.transaction do
      self.new(
          user_id: user_id,
          group_id: group_id,
          date: date,
          count: count,
          activity_type: :partner_emoney_outcome,
      ).save!
    end
  end

  #集計
  def self.activities(own_user_id, page)
    #・個人収入収支（デイリーでまとめて）
    #　　　　→　銀行出金、クレカ利用明細、電マネ利用明細等をまとめて、＠件で表示
    #　　　　　　※「振分け」も取引の増加になるため、この中に含む
    #　　　　→　クリックで個人明細画面に遷移
    #・夫婦収入収支（デイリーでまとめて）
    #　　　　→　銀行出金、クレカ利用明細、電マネ利用明細等をまとめて、＠件で表示
    #　　　　　　※「振分け」も取引の増加になるため、この中に含む
    #　　　　→　クリックで夫婦明細画面に遷移
    # TODO: ・夫婦明細のコメント入力（都度）
    # TODO:　　→　明細詳細画面遷移
    # TODO:・目標の設定

    @result = []
    own_activities = where(user_id: own_user_id).order(created_at: "DESC")
    own_activities.each {|a|
      dayStr = a.created_at.strftime('%Y-%m-%d')
      message = ""
      case a.activity_type
      when "individual_bank_outcome"
        #message = "銀行口座の支出が" + a.count.to_s + "件あります。"
        message = "銀行口座の支出があります。"
      when "individual_card_outcome"
        #message = "クレジットカードの支出が" + a.count.to_s + "件あります。"
        message = "クレジットカードの支出があります。"
      when "individual_emoney_outcome"
        #message = "電子マネーの支出が" + a.count.to_s + "件あります。"
        message = "電子マネーの支出があります。"
      when "partner_bank_outcome"
        #message = "夫婦の銀行口座の支出が" + a.count.to_s + "件あります。"
        message = "夫婦の銀行口座の支出があります。"
      when "partner_card_outcome"
        #message = "夫婦のクレジットカードの支出が" + a.count.to_s + "件あります。"
        message = "夫婦のクレジットカードの支出があります。"
      when "partner_emoney_outcome"
        #message = "夫婦の電子マネーの支出が" + a.count.to_s + "件あります。"
        message = "夫婦の電子マネーの支出があります。"
      end
      @result.push({
                       "day": dayStr,
                       "type": a.activity_type,
                       "message": message})
    }
    @result
    Kaminari.paginate_array(@result).page(page)
  end

end
