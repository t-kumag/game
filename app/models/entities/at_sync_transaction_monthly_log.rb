class Entities::AtSyncTransactionMonthlyLog < ApplicationRecord
  belongs_to :at_user_bank_account, optional: true
  belongs_to :at_user_card_account, optional: true
  belongs_to :at_user_emoney_service_account, optional: true
end
