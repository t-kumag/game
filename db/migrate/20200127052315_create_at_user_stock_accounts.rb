class CreateAtUserStockAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_stock_accounts do |t|
      t.references :at_user, foreign_key: true
      t.boolean :share
      t.references :group, foreign_key: true

      t.bigint :balance, null:false, default: 0
      t.bigint :deposit_balance, null:false, default: 0
      t.bigint :profit_loss_amount, null:false, default: 0

      t.string :fnc_id, null:false
      t.string :fnc_cd, null:false
      t.string :fnc_nm, null:false

      t.string :corp_yn, null:false
      t.string :brn_cd
      t.string :brn_nm
      t.string :memo
      t.string :use_yn, null:false
      t.string :cert_type, null:false
      t.string :sv_type, null:false

      t.datetime :scrap_dtm, null:false
      t.string :last_rslt_cd
      t.string :last_rslt_msg

      t.string :acct_no #
      t.string :acct_kind # 普通 定期 当座 普通預金 定期預金 証券決済 仕組預金 当座貸越 残高別普通


      t.datetime :error_date
      t.integer :error_count, default: 0

      t.string :cert_type, null:false # 0 : 電子証明書  1 : ID/PASSWORD 2 : IC-CARD(電子証明書)
      t.timestamps
      t.datetime :deleted_at
   end
  end
end
