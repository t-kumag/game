class CreateAtScrapingLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :at_scraping_logs do |t|
      t.references :at_user_bank_account, foreign_key: true
      t.references :at_user_card_account, foreign_key: true
      t.references :at_user_emoney_service_account, foreign_key: true
      t.timestamps
    end
  end
end
