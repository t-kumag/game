require 'nkf'

class Services::AtUserService::Sync
  def initialize(user)
    @user = user
  end

  def get_accounts_from_at
    token = @user.at_user.at_user_tokens.first.token
    params = {
      token: token
    }
    requester = AtAPIRequest::AtUser::GetAccounts.new(params)
    @accounts_from_at = AtAPIClient.new(requester).request
  end

  def sync_account(rec_key, financier_type_key, financier_entity, account_entity, data_column)
    ## db
    store_data = financier_entity.all
    fnc_cds = store_data.map(&:fnc_cd)
    financiers = store_data.map { |i| { i.fnc_cd => i } }

    ## account tracker上のデータ
    accounts = []
    if @accounts_from_at.key?(rec_key) && !@accounts_from_at[rec_key].blank?
      @accounts_from_at[rec_key].each do |i|
        financier = nil
        if fnc_cds.include?(fnc_cd: i['FNC_CD'])
          financier = financiers[i['FNC_CD']]
        else
          src_financier = financier_entity.new(fnc_cd: i['FNC_CD'], fnc_nm: i['FNC_NM'])
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
          # AT からのレスポンスに含まれないカラムはスキップする
          next if k == 'error_date' || k == 'error_count'
          if v[:opt].blank?
            account[k] = i[v[:col]]
          elsif v[:opt] == 'time_parse'
            account[k] = Time.parse(i[v[:col]])
          end
        end

        lastAccount = account_entity.find_by(fnc_id: account['fnc_id'])
        # error_count が 1以上の場合はスクレイピングしないが、バッファされたRESULT_CODEでEが返るため
        # error_count が 1未満の場合のみエラーとして扱う
        if account['last_rslt_cd'] === 'E' || account['last_rslt_cd'] === 'A'
          # 初回エラー発生時もエラーとしてカウントする
          if lastAccount.nil? || lastAccount['error_count'] < 1
            account['error_date'] = DateTime.now
            account['error_count'] = 1
          end
          # バルクインサート時にUPDATEされるようハッシュにキーを追加する
          data_column.store('error_date', '')
          data_column.store('error_count', '')
          # TODO ミロクの仕様変更によりエラーが更新毎に送信される障害発生 処理を修正する
          #MailDelivery.account_linkage_error(@user, account).deliver
        end
        accounts << account
      end
    end
    account_entity.import accounts, on_duplicate_key_update: data_column.map { |k, _v| k }, validate: false
  end

  def sync_transaction(rec_key, financier_account_type_key, account_entity, transaction_entity, data_column, has_balance = false, confirm_type = nil)
    puts 'sync transaction start ==============='
    start_date = Time.now.ago(Settings.at_sync_transaction_max_days.days).strftime('%Y%m%d')
    end_date = Time.now.strftime('%Y%m%d')
    token = @user.at_user.at_user_tokens.first.token

    # db
    category_map = Entities::AtTransactionCategory.all.map { |i| [i.at_category_id, i] }.to_h

    # ATの同期log
    sync_account_ids = []

    ## account tracker上のデータ
    account_entity.where(at_user_id: @user.at_user.id).find_each do |a|
      params = {
        token: token,
        fnc_id: a.fnc_id,
        start_date: start_date,
        end_date: end_date
      }
      # [confirm_type]クレジットカードの場合のみ利用
      # C : 確定
      # U : 確定+未確定
      # DEFAULT 'C'"
      !confirm_type.blank? && params[:confirm_type] = confirm_type

      requester = AtAPIRequest::AtUser::GetTransactions.new(params)
      res = AtAPIClient.new(requester).request

      p res

      if has_balance && res.key?('BALANCE') && !res['BALANCE'].blank?
        a.balance = res['BALANCE']
        a.save!
      end

      src_trans = []
      activities = []
      monthly_trans = []
      last_at_sync_tran_monthly_date = Services::AtSyncTransactionMonthlyDateLogService.fetch_last_one(financier_account_type_key, a)
      if res.key?(rec_key) && !res[rec_key].blank?
        res[rec_key].each do |i|
          # 文字をintに、空文字の場合は0に変換
          i['BALANCE'] = i['BALANCE'].present? ? i['BALANCE'].to_i : 0

          at_category_id = i['CATEGORY_ID']
          at_transaction_category_id = if category_map.key?(at_category_id)
                                         category_map[at_category_id].id
                                       else
                                         1 # 未分類
          end

          tran = transaction_entity.new
          # TODO
          # share: false

          tran[financier_account_type_key] = a.id # at_user_card_account_idとか
          tran[:at_transaction_category_id] = at_transaction_category_id
          data_column.each do |k, v|
            if v[:opt].blank?
              tran[k] = i[v[:col]]
            elsif  v[:opt] == 'time_parse'
              tran[k] = Time.parse(i[v[:col]])
            elsif  v[:opt] == 'time_parse_with_00:00:00'
              tran[k] = Time.parse(i[v[:col]] + 'T00:00:00+0900')
            end
          end
          src_trans << tran

          activity = get_activity(financier_account_type_key, tran, a, activities)
          monthly_trans << fetch_monthly_tran(financier_account_type_key, tran, last_at_sync_tran_monthly_date)
          activities << activity if activity.present?
        end
      end

      monthly_trans.compact!
      Services::AtSyncTransactionMonthlyDateLogService.save_at_sync_tran_monthly_date_log(monthly_trans)
      transaction_entity.import src_trans, on_duplicate_key_update: data_column.map { |k, _v| k }, validate: false
      Services::ActivityService.save_activities(activities)
      Services::AtSyncTransactionLatestDateLogService.activity_sync_log(financier_account_type_key, a)

      # ATの同期log
      sync_account_ids << {financier_account_type_key => a.id}
    end
    # ATの同期log
    Entities::AtSyncTransactionLog.insert(sync_account_ids)

  rescue AtAPIStandardError => api_err
    raise api_err
  rescue ActiveRecord::RecordInvalid => db_err
    raise db_err
  rescue => exception
    p 'exception===================='
    p exception
    p exception.backtrace
  end

  # ビジネスサイドの仕様
  # 無料会員はfnc_idごとに1日1回まで実行する
  # TODO: 1日1回という判断をどうやるか？
  # 仮仕様：レスポンスで判断する
  # ALL_CNT == 0 BASIC_DATE == null
  # の条件以外のときにat_sync_transaction_logsをinsertする
  def sync
    sync_accounts
    sync_transactions
  rescue AtAPIStandardError => api_err
    raise api_err
  rescue ActiveRecord::RecordInvalid => db_err
    raise db_err
  rescue => exception
    p 'exception===================='
    p exception
    puts exception.backtrace.join("\n")
    # p exception.backtrace
  end

  def sync_accounts
    puts 'sync_accounts=========='
    get_accounts_from_at
    sync_account(
      'CARD_DATA_REC',
      'at_card_id',
      Entities::AtCard,
      Entities::AtUserCardAccount,
      fnc_id: { col: 'FNC_ID' },
      fnc_cd: { col: 'FNC_CD' },
      fnc_nm: { col: 'FNC_NM' },
      corp_yn: { col: 'CORP_YN' },
      brn_cd: { col: 'BRN_CD' },
      brn_nm: { col: 'BRN_NM' },
      acct_no: { col: 'ACCT_NO' },
      memo: { col: 'MEMO' },
      use_yn: { col: 'USE_YN' },
      cert_type: { col: 'CERT_TYPE' },
      scrap_dtm: { col: 'SCRAP_DTM', opt: 'time_parse' },
      last_rslt_cd: { col: 'LAST_RSLT_CD' },
      last_rslt_msg: { col: 'LAST_RSLT_MSG' }
    )

    sync_account(
      'BANK_DATA_REC',
      'at_bank_id',
      Entities::AtBank,
      Entities::AtUserBankAccount,
      fnc_id: { col: 'FNC_ID' },
      fnc_cd: { col: 'FNC_CD' },
      fnc_nm: { col: 'FNC_NM' },
      corp_yn: { col: 'CORP_YN' },
      brn_cd: { col: 'BRN_CD' },
      brn_nm: { col: 'BRN_NM' },
      acct_no: { col: 'ACCT_NO' },
      acct_kind: { col: 'ACCT_KIND' },
      memo: { col: 'MEMO' },
      use_yn: { col: 'USE_YN' },
      cert_type: { col: 'CERT_TYPE' },
      scrap_dtm: { col: 'SCRAP_DTM', opt: 'time_parse' },
      last_rslt_cd: { col: 'LAST_RSLT_CD' },
      last_rslt_msg: { col: 'LAST_RSLT_MSG' }
    )

    sync_account(
      'ETC_DATA_REC',
      'at_emoney_service_id',
      Entities::AtEmoneyService,
      Entities::AtUserEmoneyServiceAccount,
      fnc_id: { col: 'FNC_ID' },
      fnc_cd: { col: 'FNC_CD' },
      fnc_nm: { col: 'FNC_NM' },
      corp_yn: { col: 'CORP_YN' },
      memo: { col: 'MEMO' },
      use_yn: { col: 'USE_YN' },
      cert_type: { col: 'CERT_TYPE' },
      scrap_dtm: { col: 'SCRAP_DTM', opt: 'time_parse' },
      last_rslt_cd: { col: 'LAST_RSLT_CD' },
      last_rslt_msg: { col: 'LAST_RSLT_MSG' }
    )
  end

  def sync_transactions
    puts 'sync_transactions=========='
    get_accounts_from_at
    sync_transaction(
      'CARD_REC',
      'at_user_card_account_id',
      Entities::AtUserCardAccount,
      Entities::AtUserCardTransaction,
      {
        branch_desc: { col: 'BRANCH_DESC' },
        used_date: { col: 'USED_DATE', opt: 'time_parse_with_00:00:00' },
        amount: { col: 'AMOUNT' },
        payment_amount: { col: 'PAYMENT_AMOUNT' },
        trade_gubun: { col: 'TRADE_GUBUN' },
        etc_desc: { col: 'ETC_DESC' },
        clm_ym: { col: 'CLM_YM' },
        crdt_setl_dt: { col: 'CRDT_SETL_DT' },
        seq: { col: 'SEQ' },
        card_no: { col: 'CARD_NO' },
        confirm_type: { col: 'CONFIRM_TYPE' }
      },
      false, # has_balance
      'U' # U: 未確定含む
    )

    sync_transaction(
      'BANK_REC',
      'at_user_bank_account_id',
      Entities::AtUserBankAccount,
      Entities::AtUserBankTransaction,
      {
        # TODO: date => dtmに変える
        trade_date: { col: 'TRADE_DTM', opt: 'time_parse' },
        amount_receipt: { col: 'AMOUNT_RECEIPT' },
        amount_payment: { col: 'AMOUNT_PAYMENT' },
        balance: { col: 'BALANCE' },
        currency: { col: 'CURRENCY' },
        description1: { col: 'DESCRIPTION1' },
        description2: { col: 'DESCRIPTION2' },
        description3: { col: 'DESCRIPTION3' },
        description4: { col: 'DESCRIPTION4' },
        description5: { col: 'DESCRIPTION5' },
        seq: { col: 'SEQ' }
      },
      true # has_balance
    )

    sync_transaction(
      'ETC_REC',
      'at_user_emoney_service_account_id',
      Entities::AtUserEmoneyServiceAccount,
      Entities::AtUserEmoneyTransaction,
      {
        used_date: { col: 'USED_DATE', opt: 'time_parse_with_00:00:00' },
        used_time: { col: 'USED_TIME' },
        description: { col: 'DESCRIPTION' },
        amount_receipt: { col: 'AMOUNT_RECEIPT' },
        amount_payment: { col: 'AMOUNT_PAYMENT' },
        balance: { col: 'BALANCE' },
        seq: { col: 'SEQ' }
      },
      true # has_balance
    )
  end

  private

  def get_activity(financier_account_type_key, tran, account, activities)
    activity = Services::ActivityService.set_activity_list(financier_account_type_key, tran, account, @user)
    check_duplicate_activity = Services::ActivityService.check_activity_duplication(financier_account_type_key, activities, activity)
    latest_sync_date = Services::AtSyncTransactionLatestDateLogService.get_latest_one(financier_account_type_key, account)
    check_difference_date = latest_sync_date.present? && latest_sync_date < activity[:date] ? true : false

    return activity if check_duplicate_activity && check_difference_date
  end

  def fetch_monthly_tran(financier_account_type_key, tran, last_at_sync_tran_monthly_date)
    at_sync_tran_monthly_date_log = Services::AtSyncTransactionMonthlyDateLogService.set_at_sync_tran_monthly_date_log(financier_account_type_key, tran)
    return at_sync_tran_monthly_date_log unless last_at_sync_tran_monthly_date.present?
    # time関数の表記とDBとでは時間の表示のずれがありこの処理を追加
    # Sun, 01 Sep 2019 00:00:00 JST +09:00
    # :monthly_date=>"2019-09-01 00:00:00" 　→　こちらで統一
    last_at_sync_tran_monthly_date = last_at_sync_tran_monthly_date.monthly_date.strftime('%Y-%m-01 %H:%M:%S')
    at_sync_tran_monthly_date_log unless at_sync_tran_monthly_date_log[:monthly_date]  <= last_at_sync_tran_monthly_date ? true : false
  end
end
