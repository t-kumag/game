# == Schema Information
#
# Table name: at_transaction_categories
#
#  id             :bigint(8)        not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  at_category_id :string(255)      not null
#  category_name1 :string(255)
#  category_name2 :string(255)
#

class Entities::AtTransactionCategory < ApplicationRecord
  belongs_to :at_grouped_category
end
