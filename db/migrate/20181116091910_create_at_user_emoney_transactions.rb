class CreateAtUserEmoneyTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_emoney_transactions do |t|

      t.references :at_user_emoney_service_account, foreign_key: true

      t.date :used_date, null: false # YYYYMMDD
      t.string :used_time  # HHMI
      
      t.string :branch_desc, null: false # 加盟店名
      t.string :description

      t.decimal :amount_receipt, precision: 16, scale: 2 null: false # チャージ金額
      t.decimal :amount_payment, precision: 16, scale: 2 null: false # 支払金額

      t.decimal :balance, precision: 18, scale: 2

      t.integer :seq, null: false

      t.references :at_transaction_category, null: false, foreign_key: true


      # 電子マネー、ポイント取引内訳反復部, ETC_REC, , , , , 
      # 利用日時, USED_DATE, 半角, 8 , ○, , YYYYMMDD
      # 利用時間, USED_TIME, 半角, 4 , , , ある場合 HHMI
      # 内容, DESCRIPTION, 全角・半角英数字, 100 , , , ある場合
      # 積立金額, AMOUNT_RECEIPT, 半角, 15 , ○, , チャージ金額
      # 支払金額, AMOUNT_PAYMENT, 半角, 15 , ○, , 支払金額
      # 残高, BALANCE, 半角, 15 , , , ある場合
      # 一連番号, SEQ, 半角, 100 , ○, , 
      # カテゴリーコード, CATEGORY_ID, 半角英数, 4 , , , "カテゴリー分類コード
      # 例:0102"
      # カテゴリー大分類, CATEGORY_NAME1, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー大分類情報例:食費
      # カテゴリー小分類, CATEGORY_NAME2, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー小分類情報例:外食

      # スクレイピング応答コード, SCRP_RSLT_CD, 半角数, 8 , ○, , "最終スクレイピングの実行状態/結果コード
      # 例:00000000"
      # 反復部区分, REC_TYPE, 半角英記, 7 , ○, , ‘ETC_REC’:電子マネー取引内訳
      # 反復部総件数, REC_CNT, 半角数, 1,000 , 半角数, , "照会件数
      # 例:80"
      # 現在のページ番号, PAGE_INDEX, 半角数, 100 , ○, , ページ区分を利用しなし：1
      # 次のページ有無, NEXTPAGE_YN, 半角英, 1 , ○, , ページ区分を利用しない：N
      # 残高, BALANCE, 半角数, 20 , , , 
      # 全体件数, ALL_CNT, 半角数, 1,000 , 半角数, , 照会件数 例:130
      
      # -----------------------------------------------------------
      # 口座取引内訳反復部, BANK_REC, , , , , 
      # 取引日時, TRADE_DTM, 半角数, 14 , ○, , 例:20180208000000     20180208121500     20180208121533 YYYYMMDDHHMISS
      # 入金額, AMOUNT_RECEIPT, 半角数記, 15 , ○, , 金額がマイナスの場合もある。 例:-10000
      # 出金額, AMOUNT_PAYMENT, 半角数記, 15 , ○, , 金額がマイナスの場合もある。 例:-10000
      # 取引後残高, BALANCE, 半角数記, 15 , , , 金額がマイナスの場合もある。 例:-10000
      # 通貨コード, CURRENCY, 半角英, 3 , ○, , JPY
      # 摘要1, DESCRIPTION1, 全角・半角英数字, 200 , ○, , 銀行サイト側で表示されtる摘要欄の情報が表示されます.
      # 摘要2, DESCRIPTION2, 全角・半角英数字, 100 , , , 
      # 摘要3, DESCRIPTION3, 全角・半角英数字, 100 , , , 
      # 摘要4, DESCRIPTION4, 全角・半角英数字, 100 , , , 
      # 摘要5, DESCRIPTION5, 全角・半角英数字, 100 , , , 
      # 一連番号, SEQ, 半角数, 100 , ○, , FNC_ID別にuniquekey
      # カテゴリーコード, CATEGORY_ID, 半角英数, 4 , , , カテゴリー分類コード 例:0102
      # カテゴリー大分類, CATEGORY_NAME1, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー大分類情報 例:食費
      # カテゴリー小分類, CATEGORY_NAME2, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー小分類情報 例:外食
      
      # -----------------------------------------------------------
      # クレジットカード取引内訳反復部, CARD_REC, , , ○, , 
      # 利用日時, USED_DATE, 半角数, 8 , ○, , 例:20180208
      # 加盟店名, BRANCH_DESC, 全角・半角英数字, 100 , ○, , 加盟店情報 例:日の丸自動車
      # 利用金額, AMOUNT, 半角数記, 15 , ○, , 金額がマイナスの場合もあります。ほとんど利用金額と支払金額が同じですが、カード会社別に違うケースもあります。 例：分割の場合 AMOUNTは、利用金額 PAYMENT_AMOUNTは、支払金額です。　: 利用金額が20000円で2回分割の場合、　AMOUNTは、20000 PAYMENT_AMOUNTは、10000となります。
      # 支払金額, PAYMENT_AMOUNT, 半角数記, 15 , ○, , 金額がマイナスの場合もあります。
      # 支払方法, TRADE_GUBUN, 全角・半角英数字, 50 , , , サイトに表示されている文言で取得します。 例:１回、６回、リボ、均等1/10
      # 備考, ETC_DESC, 全角・半角英数字, 100 , , , サイトによっては摘要を、備考という名称で表示しています。 テーブルがある場合：取得した情報を表示します テーブルがない場合：空白
      # 決済月, CLM_YM, 半角数, 6 , ○, , クレジットカード利用者の決済月です。 YYYYMM
      # 確定区分, CONFIRM_TYPE, 半角英, 1 , ○, , 明細が確定しているか、未確定なのかを確認します。 C:確定
      # 一連番号, SEQ, 半角数, 100 , ○, , FNC_ID別にuniquekey
      # 決済日, CRDT_SETL_DT, 半角数, 2 , , , クレジットカード利用者の決済日です。 DD
      # カード番号, CARD_NO, 半角数記号, 30 , , , クレジットカード番号が請求内容にある場合 例:1234-****-****-1234
      # カテゴリーコード, CATEGORY_ID, 半角英数, 4 , , , カテゴリー分類コード例:0102
      # カテゴリー大分類, CATEGORY_NAME1, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー大分類情報例:食費
      # カテゴリー小分類, CATEGORY_NAME2, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー小分類情報例:外食
      
      # -----------------------------------------------------------
      # 電子マネー、ポイント取引内訳反復部, ETC_REC, , , , , 
      # 利用日時, USED_DATE, 半角, 8 , ○, , YYYYMMDD
      # 利用時間, USED_TIME, 半角, 4 , , , ある場合 HHMI
      # 内容, DESCRIPTION, 全角・半角英数字, 100 , , , ある場合
      # 積立金額, AMOUNT_RECEIPT, 半角, 15 , ○, , チャージ金額
      # 支払金額, AMOUNT_PAYMENT, 半角, 15 , ○, , 支払金額
      # 残高, BALANCE, 半角, 15 , , , ある場合
      # 一連番号, SEQ, 半角, 100 , ○, , 
      # カテゴリーコード, CATEGORY_ID, 半角英数, 4 , , , "カテゴリー分類コード
      # 例:0102"
      # カテゴリー大分類, CATEGORY_NAME1, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー大分類情報例:食費
      # カテゴリー小分類, CATEGORY_NAME2, 全角・半角英数字, 30 , , , 摘要情報を分析してATが分類したカテゴリー小分類情報例:外食
      
      t.timestamps
    end
  end
end
