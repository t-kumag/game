class Services::AtUserService
  # envに移す
  PWD_SALT = "osdrdev"
  ACCOUNT_NAME_PREFIX = "osdrdev"

  def initialize(user)
    @user = user
  end

  # ATユーザーの登録
  # ATに登録するid,pwd,mailはサーバーで生成
  # @return [String] トークン文字列
  def create_user

    begin
      at_user = Entities::AtUser.new(
        {user_id: @user.id}
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
      p api_arr
    rescue ActiveRecord::RecordInvalid => db_err
      p db_err
    rescue => exception
      p exception
    end

    return at_user
  end

  def at_url

    at_user = nil

    if @user&.at_user&.at_user_tokens.blank?
      at_user = self.create_user
    else
      at_user = @user.at_user 
    end

    # TODO、tokenを含まないurl返す
    # TODO: 開発用url
    return "https://atdev.369webcash.com/openlistr001.act?CHNL_ID=CHNL_OSIDORI&TOKEN_KEY=#{at_user.at_user_tokens.first.token}"
  end

  # トークンを取得、叩くごとにtokenが更新される
  def token
    api_name = "/opentoknr001.jct"
    params = {
      "CHNL_ID" => AtAPIClient::CHNL_ID,
      "USER_ID" => at_user_id,
      "USER_PW" => pwd,
    }
    res = AtAPIClient.new(api_name, params).get
    return {token: res["TOKEN_KEY"], expire_date: res["EXPI_DT"]}
  end

  # 有効な場合は有効期限が延長される
  def token_disabled?
    api_name = "/opentoknr002.jct"
    params = {
      "CHNL_ID" => AtAPIClient::CHNL_ID,
      "USER_ID" => at_user_id,
      "TOKEN_KEY" => token,
    }
    res = AtAPIClient.new(api_name, params).get

    # tokenを更新?
    return {token: res["TOKEN_KEY"], expire_date: res["EXPI_DT"]}
  end

  # 金融データ登録情報照会
  def accounts
    api_name = "/openfincr003.jct"
    params = {
      "TOKEN_KEY" => token,
    }
    res = AtAPIClient.new(api_name, params).get

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

  # ## openuserr003
  # ## トークン及びユーザーIDから、ユーザーの状態を照会します
  # https://atdev.369webcash.com/openuserr003.jct?CHNL_ID=CHNL_OSIDORI&USER_ID=osdr_dev_0001
  # {"RSLT_CD":"00000000","STATUS":"0","COMMON_HEAD":{"MESSAGE":"","CODE":"","ERROR":false},"RSLT_MSG":"","REGR_DTM":"20180822123504"}

  # ## openlistr001
  # ## トークンから口座管理及びスクレイピング実行画面を呼び出します
  # https://atdev.369webcash.com/openlistr001.act?CHNL_ID=CHNL_OSIDORI&TOKEN_KEY=Y+3NCJ8PcCaRljYEi4EXMrlJLwei2JdTjgqyRt1JvFU=

end