# == Schema Information
#
# Table name: user_manually_created_transactions
#
#  id                         :bigint(8)        not null, primary key
#  user_id                    :bigint(8)
#  group_id                   :bigint(8)
#  at_transaction_category_id :bigint(8)
#  payment_method_id          :bigint(8)
#  used_date                  :date             not null
#  title                      :string(255)
#  amount                     :integer
#  used_location              :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Entities::UserManuallyCreatedTransaction < ApplicationRecord
  belongs_to :payment_method
  belongs_to :at_transaction_category
  has_many :user_distributed_transaction, dependent: :destroy
end
