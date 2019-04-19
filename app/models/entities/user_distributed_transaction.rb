# == Schema Information
#
# Table name: user_distributed_transactions
#
#  id                                   :bigint(8)        not null, primary key
#  user_id                              :bigint(8)
#  group_id                             :bigint(8)
#  share                                :boolean
#  used_date                            :date             not null
#  at_user_bank_transaction_id          :bigint(8)
#  at_user_card_transaction_id          :bigint(8)
#  at_user_emoney_transaction_id        :bigint(8)
#  user_manually_created_transaction_id :bigint(8)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class Entities::UserDistributedTransaction < ApplicationRecord
  belongs_to :user_manually_created_transaction

end
