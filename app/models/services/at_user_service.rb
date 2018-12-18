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
      p api_err
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
    url = 'https://atdev.369webcash.com/openadd001.act'
    return {
      url: url,
      chnl_id: "CHNL_OSIDORI",
      token_key: at_user.at_user_tokens.first.token
    }
  end

  def at_user
  end

  def sync
    begin

      token = @user.at_user.at_user_tokens.first.token
      params = {
        token: token,
      }
      requester = AtAPIRequest::AtUser::GetAccounts.new(params)
      res = AtAPIClient.new(requester).request

      # # new
      src_card_accounts = []

      # # db
      osidori_fnc_cds = Entities::AtCard.all.map{|i| i.fnc_cd}
      cards = Entities::AtCard.all.map{|i| {i.fnc_cd => i}}

      if res.has_key?("CARD_DATA_REC") && !res["CARD_DATA_REC"].blank?
        res["CARD_DATA_REC"].each do |i|

          card = nil
          if osidori_fnc_cds.include?(fnc_cd: i["FNC_CD"])
            card = cards[i["FNC_CD"]]
          else
            c = Entities::AtCard.new(fnc_cd: i["FNC_CD"],fnc_nm: i["FNC_NM"])
            c.save!
            card = c
          end

          src_card_accounts << Entities::AtUserCardAccount.new(
            at_user_id: @user.at_user.id,
            at_card_id: card.id,
            share: false,
            fnc_id: i["FNC_ID"],
            fnc_cd: i["FNC_CD"],
            fnc_nm: i["FNC_NM"],
            corp_yn: i["CORP_YN"],
            brn_cd: i["BRN_CD"],
            brn_nm: i["BRN_NM"],
            acct_no: i["ACCT_NO"],
            memo: i["MEMO"],
            use_yn: i["USE_YN"],
            cert_type: i["CERT_TYPE"],
            scrap_dtm: Time.parse(i["SCRAP_DTM"]),
            last_rslt_cd: i["LAST_RSLT_CD"],
            last_rslt_msg: i["LAST_RSLT_MSG"],
          )
        end
      end
      columns = [:fnc_id, :fnc_cd, :fnc_nm, :corp_yn, :brn_cd, :brn_nm, :acct_no, :memo, :use_yn, :cert_type, :scrap_dtm, :last_rslt_cd, :last_rslt_msg]
      Entities::AtUserCardAccount.import src_card_accounts, :on_duplicate_key_update => columns, :validate => false

      #### ======================


      start_date = Time.now.ago(60.days).strftime("%Y%m%d")
      end_date = Time.now.strftime("%Y%m%d")
      Entities::AtUserCardAccount.where(at_user_id: @user.at_user.id).each do |a|
        token = @user.at_user.at_user_tokens.first.token

        # params = {
        #   token: token,
        #   fnc_id: a.fnc_id,
        # }
        # requester = AtAPIRequest::AtUser::ExecScraping.new(params)
        # res = AtAPIClient.new(requester).request

        params = {
          token: token,
          fnc_id: a.fnc_id,
          start_date: start_date,
          end_date: end_date,
        }
        # クレジットカードの場合のみ利用します。
        # C : 確定
        # U : 確定+未確定
        # DEFAULT 'C'"
        params[:confirm_type] = 'C'
        requester = AtAPIRequest::AtUser::GetTransactions.new(params)
        res = AtAPIClient.new(requester).request

        puts "======================="
        p res
        
        
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

  # トークンを取得、叩くごとにtokenが更新される
  def token

    begin
      params = {
        at_user_id: @user.at_user.id
      }
      requester = AtAPIRequest::AtUser::GetToken.new(params)
      res = AtAPIClient.new(requester).request

      token = res["TOKEN_KEY"]
      at_user_token = Entities::AtUserToken.new({
          at_user_id: @user.at_user.id,
          token: token
      })
      at_user_token.save!
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

    return token
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
      p "api_err===================="
      p api_err
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
