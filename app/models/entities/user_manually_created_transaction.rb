class Entities::UserManuallyCreatedTransaction < ApplicationRecord
  belongs_to :payment_method
  belongs_to :at_transaction_category
  has_many :user_distributed_transaction, dependent: :destroy
end
