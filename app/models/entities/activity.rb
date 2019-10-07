class Entities::Activity < ApplicationRecord

  validates :user_id, presence: true

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
end
