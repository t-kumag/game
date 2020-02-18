class Entities::AtUserBankAccount < ApplicationRecord
  RELATION_KEY = :at_user_bank_account_id.freeze

  acts_as_paranoid # 論理削除
  belongs_to :at_user
  belongs_to :at_bank
  has_many :at_user_bank_transactions
  has_many :goal_settings
  has_many :at_scraping_logs
  has_many :at_sync_transaction_logs

  def calc_balance(date)
    Entities::BalanceLog.find_by(date: date)
  end

  def calc_balances(from, to)
    Entities::BalanceLog.find_by(date: from..to)
  end

end
