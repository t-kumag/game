class Entities::AtGroupedCategory < ApplicationRecord
  has_many :at_transaction_categories
end