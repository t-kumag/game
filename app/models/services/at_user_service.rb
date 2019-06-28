require 'nkf'

class Services::AtUserService
  # envに移す
  PWD_SALT = "osdrdev"
  ACCOUNT_NAME_PREFIX = "osdrdev"

  def initialize(user, target = 'all')
    @user = user
    @target = target.blank? ? 'all' : target
    token
  end

  # ATユーザーの登録
  # ATに登録するid,pwd,mailはサーバーで生成
  # @return [String] トークン文字列
  def create_user
    begin
      require "securerandom"
      rond_id = SecureRandom.hex
      at_user = Entities::AtUser.new(
        {
          user_id: @user.id,
          at_user_id: rond_id
        }
      )
      # at_user.password = at_user.generate_at_user_password
      at_user.save!
      params = {
        at_user_id: at_user.at_user_id,
        # at_user_password: at_user.password,
        # at_user_email: at_user.at_user_email,
      }
      requester = AtAPIRequest::AtUser::CreateUser.new(params)
      res = AtAPIClient.new(requester).request
      at_user_token = Entities::AtUserToken.new({
          at_user_id: at_user.id,
          token: res["TOKEN_KEY"]
        # token.expires_at = res["EXPI_DT"]
      })
      at_user_token.save!
      at_user.at_user_tokens << at_user_token
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      p exception
    end

    return at_user
  end

  def at_url

    at_user = nil

    if @user&.at_user&.at_user_tokens.blank?
      puts "create_user ================="
      at_user = create_user
      p at_user
    else
      puts " @user.at_user ================="
      at_user = @user.at_user 
      p at_user
    end

    # TODO、tokenを含まないurl返す
    # TODO: 開発用url
    url = 'https://atdev.369webcash.com/openadd001.act'

    puts "tokens========"
    p at_user.at_user_tokens.first.token

    return {
      url: url,
      chnl_id: "CHNL_OSIDORI",
      token_key: at_user.at_user_tokens.first.token
    }
  end

  def at_user

  end

  def sync
    Services::AtUserService::Sync.new(@user).sync
  end

  # トークンを取得、叩くごとにtokenが更新される
  # TODO: ミロクにtokenの仕様を確認中（一時的な対応）
  def token
    begin
      return {} unless @user.try(:at_user).try(:at_user_tokens)

      params = {
        at_user_id: @user.at_user.id,
        token: @user.at_user.at_user_tokens.first.token
      }
      # 有効なtokenを取得する
      requester = AtAPIRequest::AtUser::GetTokenStatus.new(params)
      res = AtAPIClient.new(requester).request
      p "current token===================="
      p res

      if res.has_key?("EXPI_DT") && res["EXPI_DT"].present?
        params = {
            at_user_id: @user.at_user.id,
            token: res["TOKEN_KEY"]
        }
        # tokenを削除する
        requester = AtAPIRequest::AtUser::DeleteToken.new(params)
        res = AtAPIClient.new(requester).request
        p "delete token===================="
        p res
      end

      # tokenを取得する
      params = {
          at_user_id: @user.at_user.at_user_id
      }
      requester = AtAPIRequest::AtUser::GetToken.new(params)
      res = AtAPIClient.new(requester).request
      p "new token===================="
      p res
      params = {
          token: res["TOKEN_KEY"],
          expires_at: res["EXPI_DT"]
      }
      @user.at_user.at_user_tokens.first.update!(params)
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      p "exception===================="
      p exception
    end
    params
  end

  # 有効な場合は有効期限が延長される
  def token_disabled?
    begin
      params = {
        # "CHNL_ID" => AtAPIClient::CHNL_ID,
        at_user_id: @user.at_user.id,
        token: @user.at_user.at_user_tokens.first.token,
      }
      requester = AtAPIRequest::AtUser::GetTokenStatus.new(params)
      res = AtAPIClient.new(requester).request
      status = res["STATUS"]
      if status == "0"
        return true 
      else
        return false
      end
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      p "exception===================="
      p exception
    end
  end

  # 金融データ登録情報照会
  def accounts
    api_name = "/openfincr003.jct"
    
    params = {
      # "TOKEN_KEY" => token,
      "TOKEN_KEY" => @user.at_user.at_user_token.token
    }
    res = AtAPIClient.new(api_name, params).get
    res p

    # tokenを更新?
    # {
    # "CARD_DATA_REC":
    #[
    #{
    # "FNC_ID":"caLgM3L73wFB/8VWisAwr8NnkaTqGj6kV/d5+S5+YRoSKxVcY/dpSHfo92LUsFa/mSdeHNowy0NPcjspAVIvX6Q==",
    # "CERT_TYPE":"1",
    # "BRN_NM":"",
    # "BRN_CD":"",
    # "ORI_BANK_CD":"",
    # "ACCT_NO":"",
    # "BANK_CD":"31392009",
    # "CORP_YN":"N",
    # "USE_YN":"Y",
    # "SCRAP_DTM":"20180822130232261",
    # "LAST_RSLT_MSG":"正常",
    # "LAST_RSLT_CD":"0",
    # "BANK_NM":"楽天カード",
    # "FNC_CD":"31392009",
    # "FNC_NM":"楽天カード",
    # "MEMO":"楽天カードです",
    # "SV_TYPE":"1"}
    # ],
    # "BANK_REC_CNT":"0",
    # "API_REC_CNT":"0",
    # "API_DATA_REC":null,"INSURANCE_REC_CNT":"0","TRAF_REC_CNT":"0","SHOP_REC_CNT":"0","POINT_REC_CNT":"0","INSURANCE_DATA_REC":[],"STOCK_DATA_REC":[],"RSLT_CD":"00000000","ETC_REC_CNT":"0","ETC_DATA_REC":[],"TEL_DATA_REC":[],"POINT_DATA_REC":[],"TEL_REC_CNT":"0","CARD_REC_CNT":"1","BANK_DATA_REC":[],"RSLT_MSG":"正常","DEBIT_REC_CNT":null,"STOCK_REC_CNT":"0","DEBIT_DATA_REC":null,"TRAF_DATA_REC":[],"SHOP_DATA_REC":[]}

    return {token: res["TOKEN_KEY"], expire_date: res["EXPI_DT"]}
  end

  def delete_account(model, id)
    begin
      account = model.find(id)
      params = {}
      if account
        params[:token] = @user.at_user.token
        params[:fnc_id] = account.fnc_id
        request  = AtAPIRequest::AtUser::DeleteAccount.new(params)
        AtAPIClient.new(request).request
      end
      model.find(id).destroy
    end
  end

  # ATサービスのDBに保存されている取引明細を照会します
  def transactions
    api_name = "/openscher002.jct"
    params = {
      "TOKEN_KEY" => token,
      "FNC_ID" => fnc_id,
      "START_DATE" => start_date,
      "END_DATE" => end_date,
    }
    res = AtAPIClient.new(api_name, params).get

    return {token: res["TOKEN_KEY"], expire_date: res["EXPI_DT"]}
  end

  def exec_scraping
    puts "scraping=========="
    puts @target

    begin
      puts "scraping==========1"
      token = @user.at_user.at_user_tokens.first.token
      puts "scraping=========2"

      fnc_ids = []

      # TODO リファクタリング
      # 負荷対応ため個別に分岐
      # 証券、保険などが増えると分岐が長くなるので渡されたmodelに対して処理を行うような作りに変える
      case @target
      when 'bank'
        update_error_date(@user.at_user.at_user_bank_accounts, Entities::AtUserBankAccount)
        puts "scraping bank=========="
        fnc_ids = fnc_ids + get_fnc_ids(@user.at_user.at_user_bank_accounts, Entities::AtUserBankAccount)
      when 'card'
        update_error_date(@user.at_user.at_user_card_accounts, Entities::AtUserCardAccount)
        puts "scraping card=========="
        fnc_ids + get_fnc_ids(@user.at_user.at_user_card_accounts, Entities::AtUserCardAccount)
      when 'emoney'
        update_error_date(@user.at_user.at_user_emoney_service_accounts, Entities::AtUserEmoneyServiceAccount)
        puts "scraping emoney=========="
        fnc_ids + get_fnc_ids(@user.at_user.at_user_emoney_service_accounts, Entities::AtUserEmoneyServiceAccount)
      else
        update_error_date(@user.at_user.at_user_bank_accounts, Entities::AtUserBankAccount)
        update_error_date(@user.at_user.at_user_card_accounts, Entities::AtUserCardAccount)
        update_error_date(@user.at_user.at_user_emoney_service_accounts, Entities::AtUserEmoneyServiceAccount)
        puts "scraping all=========="
        fnc_ids + get_fnc_ids(@user.at_user.at_user_bank_accounts, Entities::AtUserBankAccount)
        fnc_ids + get_fnc_ids(@user.at_user.at_user_card_accounts, Entities::AtUserCardAccount)
        fnc_ids + get_fnc_ids(@user.at_user.at_user_emoney_service_accounts, Entities::AtUserEmoneyServiceAccount)
      end

      fnc_ids.each do |fnc_id|
        params = {
          token: token,
          fnc_id: fnc_id
        }
        requester = AtAPIRequest::AtUser::ExecScraping.new(params)
        res = AtAPIClient.new(requester).request
        # ＠TODO　↓↓実装
        # ③スクレイピングの実行（openscrpr001）レスポンスの↓で追加認証要求判定する
        # 結果区分　TRAN_TYPE　半角
        # 1 : 追加認証要求
        # 2 : スクレイピング完了
        # a.　追加認証要求ありの場合
        # →　追加認証の実行（openscrpr001）
        # b.　追加認証要求なしの場合
        # →　at_sync実行
      end
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      p "exception===================="
      p exception
    end


    
    # api_name = "/openscher002.jct"
    # params = {
    #   "TOKEN_KEY" => token,
    #   "FNC_ID" => fnc_id,
    #   "START_DATE" => start_date,
    #   "END_DATE" => end_date,
    # }
    # res = AtAPIClient.new(api_name, params).get

    # return {token: res["TOKEN_KEY"], expire_date: res["EXPI_DT"]}
  end


  def update_error_date(at_user_accounts, account_entity)
    accounts = []
    at_user_accounts.each do |account|
      # 最終スクレイピング結果をlast_rslt_cd判定
      # a.　E : エラーの場合、erro_dateをDateTime.nowで更新
      if account.last_rslt_cd == "E"
        account.error_date = DateTime.now
      # b.　0 : 正常の場合、erro_dateをnilで、error_countを0で更新
      elsif a.last_rslt_cd == "0"
        account.error_date = nil
        account.error_count = 0
      end
      accounts << account
    end
    account_entity.import accounts, on_duplicate_key_update: [:error_date, :error_count], validate: false
  end


  def update_error_count(at_user_accounts, account_entity)
    accounts = []
    at_user_accounts.each do |account|
      # error_countインクリメント処理
      account.error_count += 1
      accounts << account
    end
    account_entity.import accounts, on_duplicate_key_update: [:error_count], validate: false
  end


  def get_fnc_ids(at_user_accounts, account_entity)
    error_counts = []
    fnc_ids = at_user_accounts.map{|account| 
      # ②erro_dateとエラーカウント判定（error_date、error_count）
      # a.　error_date判定（24時間経過）
      if (DateTime.now - account.error_date).numerator > 0
        # →スクレイピング実行（openscrpr001）
        account.fnc_id
      # b.　error_date判定（24時間未経過）、error_count判定（スクレイピングエラー解消リクエスト回数3未満）
      elsif (DateTime.now - account.error_date).numerator < 0 && error_count < 3
      # →スクレイピング実行（openscrpr001）
        # error_countをインクリメントする配列作成
        error_counts << account
        account.fnc_id
      # c.　error_date判定、can_ scrape_flag判定ともに偽
      else
      # →スクレイピングしない  
      end
    }.compact
    # error_countのインクリメント関数
    update_error_count(error_counts, account_entity)

    fnc_ids
  end

  # ## openuserr003
  # ## トークン及びユーザーIDから、ユーザーの状態を照会します
  # https://atdev.369webcash.com/openuserr003.jct?CHNL_ID=CHNL_OSIDORI&USER_ID=osdr_dev_0001
  # {"RSLT_CD":"00000000","STATUS":"0","COMMON_HEAD":{"MESSAGE":"","CODE":"","ERROR":false},"RSLT_MSG":"","REGR_DTM":"20180822123504"}

  # ## openlistr001
  # ## トークンから口座管理及びスクレイピング実行画面を呼び出します
  # https://atdev.369webcash.com/openlistr001.act?CHNL_ID=CHNL_OSIDORI&TOKEN_KEY=Y+3NCJ8PcCaRljYEi4EXMrlJLwei2JdTjgqyRt1JvFU=

end
