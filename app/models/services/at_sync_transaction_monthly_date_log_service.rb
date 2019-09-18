class Services::AtSyncTransactionMonthlyDateLogService

  def self.fetch_monthly_transaction_date_from_specified_date_first(account_id, from, at_user_type)
    case at_user_type
    when "at_user_card_account"
      Entities::AtSyncTransactionMonthlyDateLog.order(monthly_date: :desc).where(at_user_card_account_id: account_id).where("monthly_date <= :last_date", last_date: from).pluck("monthly_date").first
    when "at_user_bank_account"
      Entities::AtSyncTransactionMonthlyDateLog.order(monthly_date: :desc).where(at_user_bank_account_id: account_id).where("monthly_date <= :last_date", last_date: from).pluck("monthly_date").first
    when "at_user_emoney_service_account"
      Entities::AtSyncTransactionMonthlyDateLog.order(monthly_date: :desc).where(at_user_emoney_service_account_id: account_id).where("monthly_date <= :last_date", last_date: from).pluck("monthly_date").first
    end
  end

  def self.fetch_last_one(financier_account_type_key, account)
    case financier_account_type_key
    when "at_user_card_account_id"
      Entities::AtSyncTransactionMonthlyDateLog.order(id: :desc).where(at_user_card_account_id: account.id).pluck("monthly_date").first
    when "at_user_bank_account_id"
      Entities::AtSyncTransactionMonthlyDateLog.order(id: :desc).where(at_user_bank_account_id: account.id).pluck("monthly_date").first
    when "at_user_emoney_service_account_id"
      Entities::AtSyncTransactionMonthlyDateLog.order(id: :desc).where(at_user_emoney_service_account_id: account.id).pluck("monthly_date").first
    end
  end


  def self.set_at_sync_tran_monthly_date_log(financier_account_type_key, tran)

    at_sync_tran_monthly_date_log = {}
    at_sync_tran_monthly_date_log[:at_user_bank_account_id] = nil
    at_sync_tran_monthly_date_log[:at_user_card_account_id] = nil
    at_sync_tran_monthly_date_log[:at_user_emoney_service_account_id] = nil
    finance_data_column = get_finance_data_column(financier_account_type_key)

    finance_data_column.each do |k, v|
      at_sync_tran_monthly_date_log[:at_user_bank_account_id] = nil
      if v[:col] == "USED_DATE" || v[:col] == "TRADE_DTM"
        at_sync_tran_monthly_date_log[:monthly_date] = tran[k].strftime('%Y-%m-01 %H:%M:%S')
      elsif v[:col] == "BANK_ACCOUNT"
        at_sync_tran_monthly_date_log[:at_user_bank_account_id] = tran[k]
      elsif v[:col] == "CARD_ACCOUNT"
        at_sync_tran_monthly_date_log[:at_user_card_account_id] = tran[k]
      elsif v[:col] == "EMONEY_ACCOUNT"
        at_sync_tran_monthly_date_log[:at_user_emoney_service_account_id] = tran[k]
      end
    end
    at_sync_tran_monthly_date_log
  end

  def self.save_set_at_sync_tran_monthly_date_log(monthly_trans)
    is_uniqued_monthly_trans = monthly_trans.uniq
    Entities::AtSyncTransactionMonthlyDateLog.import is_uniqued_monthly_trans, :on_duplicate_key_update =>
        [:monthly_date, :at_user_card_account_id, :at_user_emoney_service_account_id, :at_user_bank_account_id], :validate => false
  end

  private

  def self.is_uniqed_data(monthly_trans)
    is_uniqued = monthly_trans.uniq

    at_sync_tran_monthly_date_logs = is_uniqued.map { |iu|
      at_sync_tran_monthly_date_log = Entities::AtSyncTransactionMonthlyDateLog.new
      at_sync_tran_monthly_date_log.monthly_date                      = iu[:monthly_date]
      at_sync_tran_monthly_date_log.at_user_card_account_id           = iu[:at_user_card_account_id]
      at_sync_tran_monthly_date_log.at_user_emoney_service_account_id = iu[:at_user_emoney_service_account_id]
      at_sync_tran_monthly_date_log.at_user_bank_account_id           = iu[:at_user_bank_account_id]
      at_sync_tran_monthly_date_log
    }

    at_sync_tran_monthly_date_logs
  end

  def self.get_finance_data_column(financier_account_type_key)
    case financier_account_type_key
    when "at_user_card_account_id"
      get_card_activity_data_column
    when "at_user_bank_account_id"
      get_bank_activity_data_column
    when "at_user_emoney_service_account_id"
      get_emoney_activity_data_column
    end
  end

  def self.get_card_activity_data_column
    {
        used_date: { col: "USED_DATE" },
        at_user_card_account_id: { col: "CARD_ACCOUNT" },
    }
  end

  def self.get_bank_activity_data_column
    {
        trade_date: { col: "TRADE_DTM" },
        at_user_bank_account_id: { col: "BANK_ACCOUNT" },
    }
  end

  def self.get_emoney_activity_data_column
    {
        used_date: { col: "USED_DATE" },
        at_user_emoney_service_account_id: { col: "EMONEY_ACCOUNT" },
    }
  end
end
