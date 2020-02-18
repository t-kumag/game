require 'nkf'

class Services::AtUserService
  attr_writer :batch_yn

  def initialize(user, fnc_type = 'all')
    @user = user
    @fnc_type = fnc_type.blank? ? 'all' : fnc_type
    @today = Date.today
    @batch_yn = nil
    # tokenは毎回更新する 有効期限は15分
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

    rescue ActiveRecord::RecordNotUnique
      # 登録済みレコード
      return Entities::AtUser.where(user_id: @user.id).first
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

  def sync_at_user_finance
    puts 'sync_at_user_finance=========='
    Services::AtUserService::Sync.new(@user).sync
  end

  def sync_user_distributed_transaction
    puts 'sync_user_distributed_transaction=========='
    Services::UserDistributedTransactionService.new(@user, @fnc_type).sync
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
      if @batch_yn == "Y" || @batch_yn == "N"
        params[:batch_yn] = @batch_yn
      end
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
      account.each do |a|
        if a.present?
          params[:token] = @user.at_user.token
          params[:fnc_id] = a.fnc_id
          request  = AtAPIRequest::AtUser::DeleteAccount.new(params)
          AtAPIClient.new(request).request
        end
        model.find(a.id).destroy
      end
    end
  end

  def delete_user
    return unless @user.try(:at_user).try(:token).present?
    params = {
      token: @user.at_user.token
    }
    request  = AtAPIRequest::AtUser::DeleteAtUser.new(params)
    AtAPIClient.new(request).request
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

  # 抑止する口座情報取得
  def get_skip_account(fnc_id)
    Entities::AtUserBankAccount.find_by(fnc_id: fnc_id) ||
    Entities::AtUserCardAccount.find_by(fnc_id: fnc_id) ||
    Entities::AtUserEmoneyServiceAccount.find_by(fnc_id: fnc_id)
  end

  # ビジネスサイドの仕様
  # 無料会員はfnc_idごとに1日1回まで実行する
  def exec_scraping
    Services::AtUserService::Sync.new(@user).sync_accounts

    puts "scraping=========="

    begin
      puts "scraping==========1"
      token = @user.at_user.at_user_tokens.first.token
      puts "scraping=========2"

      fnc_ids = []

      # ATのスクレイピングlog
      scraping_ids = []

      # TODO リファクタリング
      # 負荷対応ため個別に分岐
      # 証券、保険などが増えると分岐が長くなるので渡されたmodelに対して処理を行うような作りに変える
      puts "scraping all=========="
      bank_accounts = @user.at_user.at_user_bank_accounts
      bank_accounts = skip_scraping(bank_accounts)
      fnc_ids = fnc_ids + bank_accounts.map{|i| i.fnc_id}
      scraping_ids << bank_accounts.map{|i| {at_user_bank_account_id: i.id} }

      card_accounts = @user.at_user.at_user_card_accounts
      card_accounts = skip_scraping(card_accounts)
      fnc_ids = fnc_ids + card_accounts.map{|i| i.fnc_id}
      scraping_ids << card_accounts.map{|i| {at_user_card_account_id: i.id} }

      emoney_accounts = @user.at_user.at_user_emoney_service_accounts
      emoney_accounts = skip_scraping(emoney_accounts)
      fnc_ids = fnc_ids + emoney_accounts.map{|i| i.fnc_id}
      scraping_ids << emoney_accounts.map{|i| {at_user_emoney_service_account_id: i.id} }


      # 口座が以上終了している場合にscrapingをskipする
      skip_ids = []
      skip_ids = get_skip_fnc_ids
      fnc_ids.each do |fnc_id|

        if skip_ids.include?(fnc_id)
          # skip_account = get_skip_account(fnc_id)
          # MailDelivery.skip_scraping(@user, skip_account).deliver
          next
        end

        params = {
          token: token,
          fnc_id: fnc_id
        }
        requester = AtAPIRequest::AtUser::ExecScraping.new(params)
        res = AtAPIClient.new(requester).request
      end

      # ATのスクレイピングlog
      Entities::AtScrapingLog.insert(scraping_ids)
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      p "exception===================="
      p exception
    end
  end

  # at_scraping_logsを確認しscraping指示をskipする
  # TODO:課金実装時に無料と有料ユーザーの処理をわける
  def skip_scraping(accounts)
    accounts.reject{ |account| account.at_scraping_logs.find_by("created_at > #{@today}").present? }
  end

  def save_balance_log
     # 残高を遡るの最大日数はATの明細保存期間に合わせて経過観察
     from = Time.now.ago(Settings.at_sync_transaction_max_days.days).strftime('%Y-%m-%d')
     @user.at_user.at_user_bank_accounts.each do |a|
       Services::FinanceService.save_balance_log(a, Entities::AtUserBankTransaction.new, from)
     end
     @user.at_user.at_user_emoney_service_accounts.each do |a|
       Services::FinanceService.save_balance_log(a, Entities::AtUserEmoneyTransaction.new, from)
     end
     # TODO お財布も同様に処理
  end
end
