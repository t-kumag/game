# == Schema Information
#
# Table name: user_transactions
#
#  id                                   :bigint(8)        not null, primary key
#  log_user_id                          :integer
#  group_id                             :integer
#  at_user_bank_transaction_id          :integer
#  at_user_card_transaction_id          :integer
#  at_user_emoney_transaction_id        :integer
#  user_manually_created_transaction_id :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  is_share                             :boolean
#

class Entities::UserTransaction < ApplicationRecord
end
