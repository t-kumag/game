namespace :balance_log do
  desc "資産残高のログ管理を行う"

  # CMD: rake balance_log:insert_monthly_amount
  # 月の最終日の23:00:00に実行する。
  # at_user_xxx_accountsのbalanceを全件取得し保存する。現在はbankとemoneyが対象。
  # gem paranoiaによりdeleted_atは含まれない。
  task insert_monthly_amount: :environment do
    Rails.logger.info("start balance_log::insert_monthly_amount ===============")

    last_date_of_current_month = Time.zone.today.end_of_month.end_of_month

    Entities::AtUser.find_each do |a|
      bank_amounts = a.try(:at_user_bank_accounts).map do |b|
        {
          at_user_bank_account_id: b.id,
          amount: b.balance,
          date: last_date_of_current_month
        }
      end
      card_amounts =  a.try(:at_user_emoney_service_accounts).map do |e|
        {
          at_user_emoney_service_account_id: e.id,
          amount: e.balance,
          date: last_date_of_current_month
        }
      end
      begin
        ActiveRecord::Base.transaction do
          puts bank_amounts
          Entities::BalanceLog.import bank_amounts if bank_amounts.present?
          puts card_amounts
          Entities::BalanceLog.import card_amounts if card_amounts.present?
        end
      rescue => e
        Rails.logger.error(e)
        Rails.logger.info("bank_amounts -> #{bank_amounts}")
        Rails.logger.info("card_amounts -> #{card_amounts}")
      end

      Rails.logger.info("end balance_log::insert_monthly_amount ===============")
    end
  end
end