class Entities::AtUserEmoneyServiceAccount < ApplicationRecord
  RELATION_KEY = :at_user_emoney_service_account_id.freeze

  acts_as_paranoid # 論理削除
  belongs_to :at_user
  has_many :at_user_emoney_transactions
  has_many :at_scraping_logs
  has_many :at_sync_transaction_logs

  # TODO ReportServiceと合わせて実装する
  def ids
    [1]
  end

  def current_month_payment(account_ids=nil)
    if account_ids.present?
      self.at_user_emoney_transactions.where(used_date: (Time.zone.today.beginning_of_month)..(Time.zone.today.end_of_month), at_user_emoney_service_account_id: account_ids).sum{|i| i.amount_payment}
    else
      self.at_user_emoney_transactions.where(used_date: (Time.zone.today.beginning_of_month)..(Time.zone.today.end_of_month)).sum{|i| i.amount_payment}
    end
  end

end
