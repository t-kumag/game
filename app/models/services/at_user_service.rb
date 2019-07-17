require 'nkf'

class Services::AtUserService

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

      ActiveRecord::Base.transaction do
        # 仮登録 randomのat_user_idを登録しat_user.idを発行する
        at_user = Entities::AtUser.new(
          {
            user_id: @user.id,
            at_user_id: SecureRandom.hex
          }
        )
        at_user.save!

        params = {
          at_user_id: "#{SecureRandom.hex}_#{at_user.id}"
        }
        requester = AtAPIRequest::AtUser::CreateUser.new(params)
        res = AtAPIClient.new(requester).request

        at_user_token = Entities::AtUserToken.new({
            at_user_id: at_user.id,
            token: res["TOKEN_KEY"],
            expires_at: res["EXPI_DT"]
        })
        at_user_token.save!

        # ATのuser作成完了後に正式なat_user_idで更新する
        at_user.update!(
            {
                at_user_id: params[:at_user_id]
            }
        )
      end

    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    Entities::AtUser.where(user_id: @user.id).first
  end

  def at_url

    if @user.at_user.blank?
      @user.at_user = create_user
    end

    Rails.logger.info("tokens========")
    Rails.logger.info(@user.at_user.at_user_tokens.first.token)

    return {
      url: "#{Settings.at_url}/openadd001.act",
      chnl_id: "CHNL_OSIDORI",
      token_key: @user.at_user.at_user_tokens.first.token
    }
  end

  def at_user

  end

  def sync
    Services::AtUserService::Sync.new(@user).sync
  end

  # トークンを取得、叩くごとにtokenが更新される
  def token

    return {} unless @user.try(:at_user).try(:at_user_tokens)
    begin
      # ミロクに確認してtokenは現状の破棄しなくても使用できるとのこと
      # 使用できないtokenがあったのはurlencodeをしていなかった事が原因
      # http://redmine.369webcash.com/issues/2319

      # params = {
      #   at_user_id: @user.at_user.id,
      #   token: @user.at_user.at_user_tokens.first.token
      # }
      # # 有効なtokenを取得する
      # requester = AtAPIRequest::AtUser::GetTokenStatus.new(params)
      # res = AtAPIClient.new(requester).request
      # p "current token===================="
      # p res
      #
      # if res.has_key?("EXPI_DT") && res["EXPI_DT"].present?
      #   params = {
      #       at_user_id: @user.at_user.id,
      #       token: res["TOKEN_KEY"]
      #   }
      #   # tokenを削除する
      #   requester = AtAPIRequest::AtUser::DeleteToken.new(params)
      #   res = AtAPIClient.new(requester).request
      #   p "delete token===================="
      #   p res
      # end

      Rails.logger.info("new token====================")
      params = {
          at_user_id: @user.at_user.at_user_id
      }
      requester = AtAPIRequest::AtUser::GetToken.new(params)
      res = AtAPIClient.new(requester).request
      Rails.logger.info(res)
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
      raise exception
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

  def reset_all_account_error
    reset_entity_error(@user.at_user.at_user_bank_accounts, Entities::AtUserBankAccount);
    reset_entity_error(@user.at_user.at_user_card_accounts, Entities::AtUserCardAccount);
    reset_entity_error(@user.at_user.at_user_emoney_service_accounts, Entities::AtUserEmoneyServiceAccount);
  end

  def reset_entity_error(accounts, entity)
    entity.import accounts.map { |a| reset_account_error(a) }, on_duplicate_key_update: [:error_date, :error_count], validate: false
  end

  def reset_account_error(account)
    if (account.error_date.present? && account.error_date + 1.days <= DateTime.now)
      account.error_date = nil
      account.error_count = 0
    end
    account
  end

  def get_skip_fnc_ids
    get_accounts_skip_fnc_ids(@user.at_user.at_user_bank_accounts) + 
    get_accounts_skip_fnc_ids(@user.at_user.at_user_card_accounts) + 
    get_accounts_skip_fnc_ids(@user.at_user.at_user_emoney_service_accounts)
  end

  def get_accounts_skip_fnc_ids(accounts)
    accounts.map { |a|
      next a.fnc_id if a.error_date.present? && a.error_date + 1.days > DateTime.now && a.error_count >= 1
      nil
    }.compact
  end

  def exec_scraping
    Services::AtUserService::Sync.new(@user).sync_accounts

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
        puts "scraping bank=========="
        fnc_ids = fnc_ids + @user.at_user.at_user_bank_accounts.map{|i| i.fnc_id}
      when 'card'
        puts "scraping card=========="
        fnc_ids = fnc_ids + @user.at_user.at_user_card_accounts.map{|i| i.fnc_id}
      when 'emoney'
        puts "scraping emoney=========="
        fnc_ids = fnc_ids + @user.at_user.at_user_emoney_service_accounts.map{|i| i.fnc_id}
      else
        puts "scraping all=========="
        fnc_ids = fnc_ids + @user.at_user.at_user_bank_accounts.map{|i| i.fnc_id}
        fnc_ids = fnc_ids + @user.at_user.at_user_card_accounts.map{|i| i.fnc_id}
        fnc_ids = fnc_ids + @user.at_user.at_user_emoney_service_accounts.map{|i| i.fnc_id}	
      end

      skip_ids = []
      case @target
      when 'bank'
        reset_entity_error(@user.at_user.at_user_bank_accounts, Entities::AtUserBankAccount);
        skip_ids = get_accounts_skip_fnc_ids(@user.at_user.at_user_bank_accounts)
      when 'card'
        reset_entity_error(@user.at_user.at_user_card_accounts, Entities::AtUserCardAccount);
        skip_ids = get_accounts_skip_fnc_ids(@user.at_user.at_user_card_accounts)
      when 'emoney'
        reset_entity_error(@user.at_user.at_user_emoney_service_accounts, Entities::AtUserEmoneyServiceAccount);    
        skip_ids = get_accounts_skip_fnc_ids(@user.at_user.at_user_emoney_service_accounts)    
      else
        reset_all_account_error
        skip_ids = get_skip_fnc_ids
      end

      fnc_ids.each do |fnc_id|
        next if skip_ids.include?(fnc_id)
        params = {
          token: token,
          fnc_id: fnc_id
        }
        requester = AtAPIRequest::AtUser::ExecScraping.new(params)
        res = AtAPIClient.new(requester).request
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

  # ## openuserr003
  # ## トークン及びユーザーIDから、ユーザーの状態を照会します
  # https://atdev.369webcash.com/openuserr003.jct?CHNL_ID=CHNL_OSIDORI&USER_ID=osdr_dev_0001
  # {"RSLT_CD":"00000000","STATUS":"0","COMMON_HEAD":{"MESSAGE":"","CODE":"","ERROR":false},"RSLT_MSG":"","REGR_DTM":"20180822123504"}

  # ## openlistr001
  # ## トークンから口座管理及びスクレイピング実行画面を呼び出します
  # https://atdev.369webcash.com/openlistr001.act?CHNL_ID=CHNL_OSIDORI&TOKEN_KEY=Y+3NCJ8PcCaRljYEi4EXMrlJLwei2JdTjgqyRt1JvFU=

end
