class CreateAtTransactionCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :at_transaction_categories do |t|

      t.timestamps
      t.string, :at_category_id, null: false
      t.string, :category_name1
      t.string, :category_name2

      # カテゴリーコード, CATEGORY_ID, 半角英数, 4 , , , カテゴリー分類コード 例:0102
      # カテゴリー大分類, CATEGORY_NAME1, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー大分類情報 例:食費
      # カテゴリー小分類, CATEGORY_NAME2, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー小分類情報 例:外食
    end
  end
end
