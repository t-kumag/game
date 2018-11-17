class CreateAtUserCardAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_card_accounts do |t|
      t.references :at_user, foreign_key: true
      t.references :at_card_id, foreign_key: true
      t.boolean :share

      t.string :fnc_id, null:false

      t.string :fnc_cd, null:false
      t.string :fnc_nm, null:false

      t.string :corp_yn, null:false

      t.string :brn_cd
      t.string :brn_nm

      t.string :acct_no
      t.string :memo 

      t.string :use_yn, null:false

      t.string :cert_type, null:false # 0 : 電子証明書  1 : ID/PASSWORD 2 : IC-CARD(電子証明書)
      t.datetime :scrap_dtm, null:false # YYYYMMDDHHMISS

      t.string :last_rslt_cd # 最終スクレイピングの実行の状態 0 : 正常 E : エラー A : 追加認証要求 C : キャンセル S : 実行中
      t.string :last_rslt_msg # 最終スクレイピングの実行の状態 0 : 正常 E : エラー A : 追加認証要求 C : キャンセル S : 実行中


      # 反復部総件数, BANK_REC_CNT, 半角数, 10 , ○, , 銀行件数
      # データ反復部, BANK_DATA_REC, , , ○, , 
      # 金融ID, FNC_ID, 半角英数記, 100 , ○, , 機関一覧のuniquekey 例:bT8qbsAw/Q+FVsOz2RNf11MmS6xz41549KE7+n1ePBLrm7GIGzZeXI3CVbOJTvZVp9t7Fum1hMbm2fhOAOBg/Kw==
      # 機関コード, FNC_CD, 半角数, 8 , ○, , ATが管理してある機関の識別コード 例:11392001
      # 機関名, FNC_NM, 英数記, 50 , ○, , 金融機関の名 例:みずほ銀行
      # 法人・個人区分, CORP_YN, 半角英, 1 , ○, , Y : 法人  N : 個人
      # 支店コード, BRN_CD, 半角数, 10 , , , 法人の場合、お客様が登録する時に入力した情報 例:001
      # 支店名, BRN_NM, 全角・半角英数記, 20 , , , 使わない
      # 口座番号/カード番号, ACCT_NO, 半角数, 30 , , , 
      # 口座種類, ACCT_KIND, 全角・半角英数記, 50 , , , 普通 定期 当座 普通預金 定期預金 証券決済 仕組預金 当座貸越 残高別普通
      # メモ, MEMO, 全角・半角英数字, 100 , , , ATへの登録(金融機関登録)時に利用します。
      # 使用/未使用(削除), USE_YN, 半角英, 1 , ○, , 登録した口座の状態を確認するフィールドです。 Y：使用中の口座 N：削除された口座（未使用）
      # 認証区分, CERT_TYPE, 半角数, 1 , ○, , 0 : 電子証明書  1 : ID/PASSWORD 2 : IC-CARD(電子証明書)
      # 最終キャッシュ更新日, SCRAP_DTM, 半角数, 20 , , , スクレイピングの最終実行日 YYYYMMDDHHMISS
      # 最終処理状態, LAST_RSLT_CD, 半角英数, 1 , , , 最終スクレイピングの実行の状態 0 : 正常 E : エラー A : 追加認証要求 C : キャンセル S : 実行中
      # 最終処理メッセージ, LAST_RSLT_MSG, 全角・半角英数字, 200 , , , 
      
      # 反復部総件数, CARD_REC_CNT, 半角数, 10 , ○, , クレジットカード会社件数
      # データ反復部, CARD_DATA_REC, , , ○, , 
      # 金融ID, FNC_ID, 半角英数記, 100 , ○, , 機関一覧のuniquekey 例:cT8qbsAw/Q+FVsOz2RNf11MmS6xz41549KE7+n1ePBLrm7GIGzZeXI3CVbOJTvZVp9t7Fum1hMbm2fhOAOBg/Kw==
      # 機関コード, FNC_CD, 半角数, 3 , ○, , ATが管理している機関を識別するコード 例:31392001
      # 機関名, FNC_NM, 英数記, 50 , ○, , 金融機関の名 例:セゾンカード
      # 法人・個人区分, CORP_YN, 半角英, 1 , ○, , Y : 法人  N : 個人
      # 支店コード, BRN_CD, 半角数, 10 , , , フィールドのみで、情報の提供は今後追加予定 対応予定スケジュールについては、別途でお知らせいたします。
      # 支店名, BRN_NM, 全角・半角英数記, 20 , , , フィールドのみで、情報の提供は今後追加予定 対応予定スケジュールについては、別途でお知らせいたします。
      # 口座番号/カード番号, ACCT_NO, 半角数, 30 , , , 
      # メモ, MEMO, 全角・半角英数字, 100 , ○, , ATへの登録(金融機関登録)時に利用します。 エンドユーザが金融機関登録時に、メモ機能として利用します。（例：○○支払い用口）
      # 使用/未使用(削除), USE_YN, 半角英, 1 , ○, , 登録した口座の状態を確認するフィールドです。Y：使用中の口座N：削除された口座（未使用）
      # 認証区分, CERT_TYPE, 半角数, 1 , ○, , クレジットカードは、2018年3月現在ID/PASSWORD方式の提供されています。 ‘1’ : ID/PASSWORD
      # 最終キャッシュ更新日, SCRAP_DTM, 半角数, 20 , , , スクレイピングの最終実行日 YYYYMMDDHHMISS
      # 最終処理状態, LAST_RSLT_CD, 半角英数, 1 , , , 最終スクレイピングの実行の状態 0 : 正常 E : エラー A : 追加認証要求
      # 最終処理メッセージ, LAST_RSLT_MSG, 全角・半角英数字, 200 , , , 
      
      # 反復部総件数, ETC_REC_CNT, 半角数, 10 , ○, , 電子マネー件数
      # データ反復部, ETC_DATA_REC, , , , , 
      # 金融ID, FNC_ID, 半角, 100 , , , 機関一覧のuniquekey 例:pT8qbsAw/Q+FVsOz2RNf11MmS6xz41549KE7+n1ePBLrm7GIGzZeXI3CVbOJTvZVp9t7Fum1hMbm2fhOAOBg/Kw==
      # 機関コード, FNC_CD, 半角, 8 , , , ATが管理している機関を識別するコード 例:31392001
      # 機関名, FNC_NM, 半角, 50 , , , 金融機関の名 例:モバイルスイカ
      # 法人・個人区分, CORP_YN, 半角, 1 , , , 電子マネーは現在は'N'しかない。 Y : 法人  N : 個人
      # メモ, MEMO, 半角, 100 , , , 
      # 使用/未使用, USE_YN, 半角, 1 , , , Y : 使用 N : 解約 T : 仮発行
      # 認証区分, CERT_TYPE, 半角, 1 , , , 現在はID/PASSWORDログイン方式だけある。 ‘1’ : ID/PASSWORD
      # 最終キャッシュ更新日, SCRAP_DTM, 半角, 30 , , , スクレイピングの最終実行日 YYYYMMDDHHMISS
      # 最終処理状態, LAST_RSLT_CD, 半角, 1 , , , 最終スクレイピングの実行の状態 0 : 正常 E : エラー A : 追加認証要求 C : キャンセル S : 実行中
      # 最終処理メッセージ, LAST_RSLT_MSG, 半角, 200 , , , 
      # 残高, BALANCE, 半角, 17 , , , 
      

      t.timestamps
    end
  end
end
