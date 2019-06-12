class Entities::Activity < ApplicationRecord

  #個人支出(銀行)
  def self.add_bank_outcome_individual(date, user_id)
    self.new(
        user_id: user_id,
        date: date,
        activity_type: :individual_bank_outcome,
    ).save!
  end

  #個人支出(カード)
  def self.add_card_outcome_individual(date, user_id)
    self.new.transaction do
      self.new(
          user_id: user_id,
          date: date,
          activity_type: :individual_card_outcome,
      ).save!
    end
  end

  #個人支出(電子マネー)
  def self.add_emoney_outcome_individual(date, user_id)
    self.new.transaction do
      self.new(
          user_id: user_id,
          date: date,
          activity_type: :individual_emoney_outcome,
      ).save!
    end
  end

  #夫婦支出(銀行)
  def self.add_bank_outcome_partner(date, user_id, partner_user_id)
    self.new.transaction do
      self.new(
          user_id: user_id,
          partner_user_id: partner_user_id,
          date: date,
          activity_type: :partner_bank_outcome,
      ).save!
    end
  end

  #夫婦支出(カード)
  def self.add_card_outcome_partner(date, user_id, partner_user_id)
    self.new.transaction do
      self.new(
          user_id: user_id,
          partner_user_id: partner_user_id,
          date: date,
          activity_type: :partner_card_outcome,
      ).save!
    end
  end

  #夫婦支出(電子マネー)
  def self.add_emoney_outcome_partner(date, user_id, partner_user_id)
    self.new.transaction do
      self.new(
          user_id: user_id,
          partner_user_id: partner_user_id,
          date: date,
          activity_type: :partner_emoney_outcome,
      ).save!
    end
  end

  #集計
  def self.activities(own_user_id)
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

    daysMap = {}
    own_activities = where(user_id: own_user_id).or(where(partner_user_id: own_user_id)).order(created_at: "DESC")
    own_activities.each {|a|
      dayStr = a.created_at.strftime('%Y-%m-%d')
      unless daysMap[dayStr]
        daysMap[dayStr] = [a]
      else
        daysMap[dayStr].push(a)
      end
    }
    @result = []

    daysMap.each {|key, value|
      out_b_count = 0
      out_c_count = 0
      out_e_count = 0
      out_p_b_count = 0
      out_p_c_count = 0
      out_p_e_count = 0
      value.each {|t|
        case
        when :individual_bank_outcome
          out_b_count += 1
        when :individual_card_outcome
          out_c_count += 1
        when :individual_emoney_outcome
          out_c_count += 1
        when :partner_bank_outcome
          out_p_b_count += 1
        when :partner_card_outcome
          out_p_c_count += 1
        when :partner_emoney_outcome
          out_p_e_count += 1
        end
      }
      @result.push({"day": key, "type": :individual_bank_outcome, "count": out_b_count}) if out_b_count > 0
      @result.push({"day": key, "type": :individual_card_outcome, "count": out_c_count}) if out_c_count > 0
      @result.push({"day": key, "type": :individual_emoney_outcome, "count": out_e_count}) if out_e_count > 0
      @result.push({"day": key, "type": :partner_bank_outcome, "count": out_p_b_count}) if out_p_b_count > 0
      @result.push({"day": key, "type": :partner_card_outcome, "count": out_p_c_count}) if out_p_c_count > 0
      @result.push({"day": key, "type": :partner_emoney_outcome, "count": out_p_e_count}) if out_p_e_count > 0
    }

    pp @result

  end

end
