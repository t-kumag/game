class AddBeforeVesionIdToAtTransactionCategories < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    add_column :at_transaction_categories, :before_version_id, :bigint, after: :at_category_id
  end
end
