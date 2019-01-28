require 'nkf'

class Services::AtUserService::Sync

  def initialize(user)
    @user = user
  end

  def get_accounts_from_at
    token = @user.at_user.at_user_tokens.first.token
    params = {
      token: token,
    }
    requester = AtAPIRequest::AtUser::GetAccounts.new(params)
    @accounts_from_at = AtAPIClient.new(requester).request
  end

  def sync_account(rec_key, financier_type_key ,financier_entity, account_entity, data_column)
    
    ## db
    store_data = financier_entity.all
    fnc_cds = store_data.map{|i| i.fnc_cd}
    financiers = store_data.map{|i| {i.fnc_cd => i}}

    ## account tracker上のデータ
    accounts = []
    if @accounts_from_at.has_key?(rec_key) && !@accounts_from_at[rec_key].blank?
      @accounts_from_at[rec_key].each do |i|
        financier = nil
        if fnc_cds.include?(fnc_cd: i["FNC_CD"])
          financier = financiers[i["FNC_CD"]]
        else
          src_financier = financier_entity.new(fnc_cd: i["FNC_CD"],fnc_nm: i["FNC_NM"])
          src_financier.save!
          financier = src_financier
        end

        account = account_entity.new(
          at_user_id: @user.at_user.id,
          # at_card_id: card.id,
          share: false
        )
        account[financier_type_key] = financier.id
        data_column.each do |k, v|
          if v[:opt].blank?
            account[k] = i[v[:col]]
          elsif  v[:opt] == "time_parse"
            account[k] = Time.parse(i[v[:col]])
          end
        end
        accounts << account
      end
    end
    account_entity.import accounts, :on_duplicate_key_update => data_column.map{|k,v| return k }, :validate => false
  end

  def sync_transaction
    begin
      puts "sync sync_card_transaction start ==============="
      start_date = Time.now.ago(60.days).strftime("%Y%m%d")
      end_date = Time.now.strftime("%Y%m%d")
      token = @user.at_user.at_user_tokens.first.token
      
      rec_key
      financier_type_key
      financier_entity
      account_entity
      transaction_entity
      data_column ={
        used_date: {col: "USED_DATE"},
        branch_desc: {col: "BRANCH_DESC"},
        amount: {col: "AMOUNT"},
        payment_amount: {col: "PAYMENT_AMOUNT"},
        trade_gubun: {col: "TRADE_GUBUN"},
        etc_desc: {col: "ETC_DESC"},
        clm_ym: {col: "CLM_YM"},
        crdt_setl_dt: {col: "CRDT_SETL_DT"},
        seq: {col: "SEQ"},
        card_no: {col: "CARD_NO"},
        confirm_type: {col: "CONFIRM_TYPE"},
      }

      amount: i["AMOUNT"], # 利用額
      payment_amount: i["PAYMENT_AMOUNT"], # 支払金額
      trade_gubun: i["TRADE_GUBUN"], # 支払方法 1回払い
      etc_desc: i["ETC_DESC"], # 備考
      clm_ym: i["CLM_YM"], # 決済月 "YYYYMM? 2019-01
      crdt_setl_dt: i["CRDT_SETL_DT"], # 決済日 DD 27
      seq: i["SEQ"],
      card_no: i["CARD_NO"], # マスクされている下4桁のみ保持
      confirm_type: i["CONFIRM_TYPE"], # 明細が確定しているか、未確定なのかを確認します。C:確定

      # CARD_REC	"クレジットカード取引内訳
      # 反復部"	
      # USED_DATE	利用日時	半角数
      # BRANCH_DESC	加盟店名	全角・半角英数字
      # AMOUNT	利用金額	半角数記
      # PAYMENT_AMOUNT	支払金額	半角数記
      # TRADE_GUBUN	支払方法	全角・半角英数字
      # ETC_DESC	備考	全角・半角英数字
      # CLM_YM	決済月	半角数
      # CONFIRM_TYPE	確定区分	半角英
      # SEQ	一連番号	半角数
      # CRDT_SETL_DT	決済日	半角数
      # CARD_NO	カード番号	半角数記号

      # CATEGORY_ID	カテゴリーコード	半角英数
      # CATEGORY_NAME1	カテゴリー大分類	全角・半角英数字
      # CATEGORY_NAME2	カテゴリー小分類	全角・半角英数字

      account_entity.where(at_user_id: @user.at_user.id).each do |a|
        puts "sync sync_card_transaction start 1==============="

        params = {
          token: token,
          fnc_id: a.fnc_id,
          start_date: start_date,
          end_date: end_date,          
        }

        # [confirm_type]クレジットカードの場合のみ利用します。
        # C : 確定
        # U : 確定+未確定
        # DEFAULT 'C'"
        params[:confirm_type] = 'U'
        puts "sync sync_card_transaction start 2==============="
        requester = AtAPIRequest::AtUser::GetTransactions.new(params)
        res = AtAPIClient.new(requester).request
        puts "sync sync_card_transaction start 3==============="
        p res


        src_card_trans = []
        if res.has_key?("CARD_REC") && !res["CARD_REC"].blank?
          res["CARD_REC"].each do |i|

            # TODO: category
            # i["CATEGORY_ID"]
            # i["CATEGORY_NAME1"]
            # i["CATEGORY_NAME2"]

            # # カナ 半角 => 全角
            # branch_desc = NKF::nkf( '-WwXm0', i["BRANCH_DESC"])
            
            # 利用日
            used_date = nil
            used_date = DateTime.parse(i["USED_DATE"]).to_date if res.has_key?("USED_DATE") && !res["USED_DATE"].blank?
            src_card_trans << Entities::AtUserCardTransaction.new(
              at_user_card_account_id: a.id,
              used_date: used_date, # 利用日時 YYYYMMDD? 2018-12-12
              branch_desc: branch_desc, # 加盟店名
              amount: i["AMOUNT"], # 利用額
              payment_amount: i["PAYMENT_AMOUNT"], # 支払金額
              trade_gubun: i["TRADE_GUBUN"], # 支払方法 1回払い
              etc_desc: i["ETC_DESC"], # 備考
              clm_ym: i["CLM_YM"], # 決済月 "YYYYMM? 2019-01
              crdt_setl_dt: i["CRDT_SETL_DT"], # 決済日 DD 27
              seq: i["SEQ"],
              card_no: i["CARD_NO"], # マスクされている下4桁のみ保持
              confirm_type: i["CONFIRM_TYPE"], # 明細が確定しているか、未確定なのかを確認します。C:確定
              # at_transaction_category_id: ,            
            )
          end
        end

        columns = [:used_date ,:branch_desc, :amount, :payment_amount, :trade_gubun, :etc_desc, :clm_ym, :crdt_setl_dt, :seq, :card_no, :confirm_type]
        Entities::AtUserCardTransaction.import src_card_trans, :on_duplicate_key_update => columns, :validate => false
          
      end

    rescue AtAPIStandardError => api_err
      p "api_err===================="
      p api_err
    rescue ActiveRecord::RecordInvalid => db_err
      p "db_err===================="
      p db_err
    rescue => exception
      p "exception===================="
      p exception
    end
  end

  def sync
    begin
      ## accounts ##############
      get_accounts_from_at

      sync_account(
        "CARD_DATA_REC",
        "at_card_id",         
        Entities::AtCard,
        Entities::AtUserCardAccount,
        {
          fnc_id: {col: "FNC_ID" },
          fnc_cd: {col: "FNC_CD" },
          fnc_nm: {col: "FNC_NM" },
          corp_yn: {col: "CORP_YN" },
          brn_cd: {col: "BRN_CD" },
          brn_nm: {col: "BRN_NM" },
          acct_no: {col: "ACCT_NO" },
          memo: {col: "MEMO" },
          use_yn: {col: "USE_YN" },
          cert_type: {col: "CERT_TYPE" },
          scrap_dtm: {col: "SCRAP_DTM", opt: "time_parse" },
          last_rslt_cd: {col:"LAST_RSLT_CD" },
          last_rslt_msg: {col: "LAST_RSLT_MSG" }
        }
      )

      sync_account(
        "BANK_DATA_REC",
        "at_bank_id",
        Entities::AtBank,
        Entities::AtUserBankAccount,
        {
          fnc_id: {col: "FNC_ID" },
          fnc_cd: {col: "FNC_CD" },
          fnc_nm: {col: "FNC_NM" },
          corp_yn: {col: "CORP_YN" },
          brn_cd: {col: "BRN_CD" },
          brn_nm: {col: "BRN_NM" },
          acct_no: {col: "ACCT_NO" },
          acct_kind: {col: "ACCT_KIND"},
          memo: {col: "MEMO" },
          use_yn: {col: "USE_YN" },
          cert_type: {col: "CERT_TYPE" },
          scrap_dtm: {col: "SCRAP_DTM", opt: "time_parse" },
          last_rslt_cd: {col:"LAST_RSLT_CD" },
          last_rslt_msg: {col: "LAST_RSLT_MSG" }
        }
      )

      sync_account(
        "ETC_DATA_REC",
        "at_emoney_service_id",
        Entities::AtEmoneyService,
        Entities::AtUserEmoneyServiceAccount,
        {
          fnc_id: {col: "FNC_ID" },
          fnc_cd: {col: "FNC_CD" },
          fnc_nm: {col: "FNC_NM" },
          corp_yn: {col: "CORP_YN" },
          memo: {col: "MEMO" },
          use_yn: {col: "USE_YN" },
          cert_type: {col: "CERT_TYPE" },
          scrap_dtm: {col: "SCRAP_DTM", opt: "time_parse" },
          last_rslt_cd: {col:"LAST_RSLT_CD" },
          last_rslt_msg: {col: "LAST_RSLT_MSG" }
        }
      )

      # puts "sync sync_card_transaction start ==============="

      # sync_card_transaction

      # puts "sync sync_bank_transaction start ==============="
      # sync_bank_transaction

      # puts "sync sync_emoney_transaction start ==============="
      # sync_emoney_transaction

    rescue AtAPIStandardError => api_err
      p "api_err===================="
      p api_err
    rescue ActiveRecord::RecordInvalid => db_err
      p "db_err===================="
      p db_err
    rescue => exception
      p "exception===================="
      p exception
    end
  end




  def sync_card_transaction
    begin
      # TODO: 期間指定
      puts "sync sync_card_transaction start ==============="
      start_date = Time.now.ago(60.days).strftime("%Y%m%d")
      end_date = Time.now.strftime("%Y%m%d")
      token = @user.at_user.at_user_tokens.first.token
      Entities::AtUserCardAccount.where(at_user_id: @user.at_user.id).each do |a|
        puts "sync sync_card_transaction start 1==============="
        params = {
          token: token,
          fnc_id: a.fnc_id,
          start_date: start_date,
          end_date: end_date,          
        }
        # [confirm_type]クレジットカードの場合のみ利用します。
        # C : 確定
        # U : 確定+未確定
        # DEFAULT 'C'"
        params[:confirm_type] = 'U'
        puts "sync sync_card_transaction start 2==============="
        requester = AtAPIRequest::AtUser::GetTransactions.new(params)
        res = AtAPIClient.new(requester).request
        puts "sync sync_card_transaction start 3==============="
        p res


        src_card_trans = []
        if res.has_key?("CARD_REC") && !res["CARD_REC"].blank?
          res["CARD_REC"].each do |i|

            # TODO: category
            # i["CATEGORY_ID"]
            # i["CATEGORY_NAME1"]
            # i["CATEGORY_NAME2"]

            # カナ 半角 => 全角
            branch_desc = NKF::nkf( '-WwXm0', i["BRANCH_DESC"])
            
            # 利用日
            used_date = nil
            used_date = DateTime.parse(i["USED_DATE"]).to_date if res.has_key?("USED_DATE") && !res["USED_DATE"].blank?
            src_card_trans << Entities::AtUserCardTransaction.new(
              at_user_card_account_id: a.id,
              used_date: used_date, # 利用日時 YYYYMMDD? 2018-12-12
              branch_desc: branch_desc, # 加盟店名
              amount: i["AMOUNT"], # 利用額
              payment_amount: i["PAYMENT_AMOUNT"], # 支払金額
              trade_gubun: i["TRADE_GUBUN"], # 支払方法 1回払い
              etc_desc: i["ETC_DESC"], # 備考
              clm_ym: i["CLM_YM"], # 決済月 "YYYYMM? 2019-01
              crdt_setl_dt: i["CRDT_SETL_DT"], # 決済日 DD 27
              seq: i["SEQ"],
              card_no: i["CARD_NO"], # マスクされている下4桁のみ保持
              confirm_type: i["CONFIRM_TYPE"], # 明細が確定しているか、未確定なのかを確認します。C:確定
              # at_transaction_category_id: ,            
            )
          end
        end
        p src_card_trans
        columns = [:used_date ,:branch_desc, :amount, :payment_amount, :trade_gubun, :etc_desc, :clm_ym, :crdt_setl_dt, :seq, :card_no, :confirm_type]
        Entities::AtUserCardTransaction.import src_card_trans, :on_duplicate_key_update => columns, :validate => false
          
      end

    rescue AtAPIStandardError => api_err
      p "api_err===================="
      p api_err
    rescue ActiveRecord::RecordInvalid => db_err
      p "db_err===================="
      p db_err
    rescue => exception
      p "exception===================="
      p exception
    end
  end

  def sync_bank_transaction
    begin
      # TODO: 期間指定
      start_date = Time.now.ago(60.days).strftime("%Y%m%d")
      end_date = Time.now.strftime("%Y%m%d")
      token = @user.at_user.at_user_tokens.first.token
      Entities::AtUserBankAccount.where(at_user_id: @user.at_user.id).each do |a|
        params = {
          token: token,
          fnc_id: a.fnc_id,
          start_date: start_date,
          end_date: end_date,          
        }
        requester = AtAPIRequest::AtUser::GetTransactions.new()
        res = AtAPIClient.new(requester).request

        src_bank_trans = []
        if res.has_key?("BANK_REC") && !res["BANK_REC"].blank?
          res["BANK_REC"].each do |i|

            # TODO: category
            # i["CATEGORY_ID"]
            # i["CATEGORY_NAME1"]
            # i["CATEGORY_NAME2"]

            # CATEGORY_ID	カテゴリーコード
            # CATEGORY_NAME1	カテゴリー大分類
            # CATEGORY_NAME2	カテゴリー小分類

            # # カナ 半角 => 全角
            # branch_desc = NKF::nkf( '-WwXm0', i["BRANCH_DESC"])
            
            # 利用日時
            # YYYYMMDDHHMISS
            trade_dtm = nil
            trade_dtm = DateTime.parse(i["TRADE_DTM"]) if res.has_key?("TRADE_DTM") && !res["TRADE_DTM"].blank?
            src_card_trans << Entities::AtUserCardTransaction.new(
              at_user_card_account_id: a.id,
              trade_dtm: trade_dtm, # 利用日時 YYYYMMDDHHMISS

              amount_receipt: i["AMOUNT_RECEIPT"], # AMOUNT_RECEIPT	入金額
              amount_payment: i["AMOUNT_PAYMENT"], # AMOUNT_PAYMENT	出金額
              balance: i["BALANCE"], # BALANCE	取引後残高
              currency: i["CURRENCY"], # CURRENCY	通貨コード
              description1: i["DESCRIPTION1"], # DESCRIPTION1	摘要1
              description2: i["DESCRIPTION2"], # DESCRIPTION2	摘要2
              description3: i["DESCRIPTION3"], # DESCRIPTION3	摘要3
              description4: i["DESCRIPTION4"], # DESCRIPTION4	摘要4
              description5: i["DESCRIPTION5"], # DESCRIPTION5	摘要5
              seq: i["SEQ"], # SEQ	一連番号
              # at_transaction_category_id: ,            
            )
          end
        end
        p src_bank_trans
        columns = [:trade_dtm ,:amount_receipt, :amount_payment, :balance, :currency, :description1, :description2, :description3, :description4, :description5, :seq]
        Entities::AtUserBankTransaction.import src_bank_trans, :on_duplicate_key_update => columns, :validate => false
          
      end

    rescue AtAPIStandardError => api_err
      p "api_err===================="
      p api_err
    rescue ActiveRecord::RecordInvalid => db_err
      p "db_err===================="
      p db_err
    rescue => exception
      p "exception===================="
      p exception
    end
  end
  
  def sync_emoney_transaction
    begin
      # TODO: 期間指定
      start_date = Time.now.ago(60.days).strftime("%Y%m%d")
      end_date = Time.now.strftime("%Y%m%d")
      token = @user.at_user.at_user_tokens.first.token
      p "sync_emoney_transaction ===================="
      Entities::AtUserEmoneyServiceAccount.where(at_user_id: @user.at_user.id).each do |a|
        params = {
          token: token,
          fnc_id: a.fnc_id,
          start_date: start_date,
          end_date: end_date,          
        }
        p "sync_emoney_transaction1 ===================="
        requester = AtAPIRequest::AtUser::GetTransactions.new(params)
        res = AtAPIClient.new(requester).request
        p "sync_emoney_transaction2 ===================="

        src_emoney_trans = []
        if res.has_key?("ETC_REC") && !res["ETC_REC"].blank?
          res["ETC_REC"].each do |i|

            # TODO: category
            # i["CATEGORY_ID"]
            # i["CATEGORY_NAME1"]
            # i["CATEGORY_NAME2"]

            # CATEGORY_ID	カテゴリーコード
            # CATEGORY_NAME1	カテゴリー大分類
            # CATEGORY_NAME2	カテゴリー小分類

            # # カナ 半角 => 全角
            # branch_desc = NKF::nkf( '-WwXm0', i["BRANCH_DESC"])
            
            # 利用日時
            # YYYYMMDDHHMISS
            # 利用日
            used_date = nil
            used_date = DateTime.parse(i["USED_DATE"]).to_date if res.has_key?("USED_DATE") && !res["USED_DATE"].blank?
            src_emoney_trans << Entities::AtUserEmoneyTransaction.new(
              at_user_emoney_service_account_id: a.id,
              used_date: used_date, # 利用日時 YYYYMMDDHHMISS
              used_time: i["USED_TIME"], # 利用日時 YYYYMMDDHHMISS
              amount_receipt: i["AMOUNT_RECEIPT"], # AMOUNT_RECEIPT	入金額
              amount_payment: i["AMOUNT_PAYMENT"], # AMOUNT_PAYMENT	出金額
              description: i["DESCRIPTION"], # DESCRIPTION1	摘要1
              balance: i["BALANCE"], # BALANCE	取引後残高
              seq: i["SEQ"], # SEQ	一連番号
              # at_transaction_category_id: ,            
            )
          end
        end
        p src_emoney_trans
        columns = [:used_date, :used_time, :amount_receipt, :amount_payment, :balance, :description, :seq]
        Entities::AtUserEmoneyTransaction.import src_emoney_trans, :on_duplicate_key_update => columns, :validate => false
          
      end

    rescue AtAPIStandardError => api_err
      p "api_err===================="
      p api_err
    rescue ActiveRecord::RecordInvalid => db_err
      p "db_err===================="
      p db_err
    rescue => exception
      p "exception===================="
      p exception
    end
  end
  

end
