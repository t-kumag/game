class Services::AtSyncTransactionMonthlyDateLogService

  def self.latest_transaction_monthly_date(account_id, to, at_user_type)
    case at_user_type
    when "at_user_card_account"
      Entities::AtSyncTransactionMonthlyDateLog.order(monthly_date: :desc).where(at_user_card_account_id: account_id).where("monthly_date <= :last_date", last_date: to.next_day(1)).pluck("monthly_date")
    when "at_user_bank_account"
      Entities::AtSyncTransactionMonthlyDateLog.order(monthly_date: :desc).where(at_user_bank_account_id: account_id).where("monthly_date <= :last_date", last_date: to.next_day(1)).pluck("monthly_date")
    when "at_user_emoney_service_account"
      Entities::AtSyncTransactionMonthlyDateLog.order(monthly_date: :desc).where(at_user_emoney_service_account_id: account_id).where("monthly_date <= :last_date", last_date: to.next_day(1)).pluck("monthly_date")
    end
  end

end
