class Entities::AtUserStockAccount < ApplicationRecord
  RELATION_KEY = 'at_user_stock_account_id'.freeze

  acts_as_paranoid # 論理削除
  belongs_to :at_user
  has_many :at_user_asset_products
  has_many :at_user_stock_logs
end
