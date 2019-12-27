module AtAPIRequest
  module HttpMethod
    GET = "get"
    POST = "post"
  end

  class Request
    PWD_SALT = Settings.at_pwd_salt
    ACCOUNT_NAME_PREFIX = Settings.at_account_name_prefix
    CHNL_ID = Settings.at_chnl_id
    URL = Settings.at_url
    attr_reader :path, :params, :url, :method

    Rails.logger.info("PWD_SALT: #{PWD_SALT}")
    Rails.logger.info("ACCOUNT_NAME_PREFIX: #{ACCOUNT_NAME_PREFIX}")
    Rails.logger.info("CHNL_ID: #{CHNL_ID}")
    Rails.logger.info("URL: #{URL}")

    def url
      URL
    end
  end

  module AtUser
    class CreateUser < AtAPIRequest::Request
      # build request parameter
      def initialize(params)
        @path = "/openuserc001.jct"
        @method = HttpMethod::POST

        at_user_id = "#{ACCOUNT_NAME_PREFIX}_#{params[:at_user_id]}"

        @params = {
          "CHNL_ID" => AtAPIRequest::Request::CHNL_ID,
          "USER_ID" => at_user_id,
          # "USER_PW" => params[:at_user_password],
          # "EMAIL_ADDR" => params[:at_user_email],
        }
      end
    end

    # params = {
    #   at_user_id: "",
    #   at_user_password: "",
    # }
    class GetAtUrl < AtAPIRequest::Request
      def initialize(params)
        @path = "/opentoknr002.jct"
        @method = HttpMethod::GET
        at_user_id = "#{ACCOUNT_NAME_PREFIX}_#{params[:at_user_id]}"
        @params = {
          "CHNL_ID" => AtAPIRequest::Request::CHNL_ID,
          "USER_ID" => at_user_id,
          "USER_PW" => params[:at_user_password],
        }
      end
    end

    class GetToken < AtAPIRequest::Request
      def initialize(params)
        @path = "/opentoknr001.jct"
        @method = HttpMethod::GET
        @params = {
          "CHNL_ID" => AtAPIRequest::Request::CHNL_ID,
          "USER_ID" => "#{ACCOUNT_NAME_PREFIX}_#{params[:at_user_id]}",
          # "USER_PW" => params[:at_user_password],
        }
      end
    end

    class DeleteToken < AtAPIRequest::Request
      def initialize(params)
        @path = "/opentoknd001.jct"
        @method = HttpMethod::GET
        @params = {
            "TOKEN_KEY" => params[:token]
        }
      end
    end

    # 有効な場合は有効期限が延長される
    class GetTokenStatus < AtAPIRequest::Request
      def initialize(params)
        @path = "/opentoknr002.jct"
        @method = HttpMethod::GET
        @params = {
          "CHNL_ID" => AtAPIRequest::Request::CHNL_ID,
          "USER_ID" => "#{ACCOUNT_NAME_PREFIX}_#{params[:at_user_id]}",
          "TOKEN_KEY" => params[:token],
        }
      end
    end

    # # 有効な場合は有効期限が延長される
    # def token_disabled?
    #   api_name = "/opentoknr002.jct"
    #   params = {
    #     "CHNL_ID" => AtAPIClient::CHNL_ID,
    #     "USER_ID" => at_user_id,
    #     "TOKEN_KEY" => token,
    #   }
    #   res = AtAPIClient.new(api_name, params).get
    #   # tokenを更新?
    #   return {token: res["TOKEN_KEY"], expire_date: res["EXPI_DT"]}
    # end

    class GetAccounts < AtAPIRequest::Request
      def initialize(params)
        @path = "/openfincr003.jct"
        @method = HttpMethod::GET
        @params = {
          "TOKEN_KEY" => params[:token],
          "FNC_TYPE"  => params[:fnc_type]
        }
      end
    end

    class GetTransactions < AtAPIRequest::Request
      def initialize(params)
        @path = "/openscher002.jct"
        @method = HttpMethod::GET
        @params = {
          "TOKEN_KEY" => params[:token],
          "FNC_ID" => params[:fnc_id],
          "START_DATE" => params[:start_date], # ‘YYYYMMDD’
          "END_DATE" => params[:end_date], # ‘YYYYMMDD’
        }
        @params["ROW_SIZE"] = 2000
        @params["ROW_SIZE"] = params[:row_size] if params.has_key?(:row_size) || !params[:row_size].blank?
        @params["CONFIRM_TYPE"] = params[:confirm_type] if params.has_key?(:confirm_type) || !params[:confirm_type].blank?
      end
    end

    class ExecScraping < AtAPIRequest::Request
      def initialize(params)
        @path = "/openscrpr001.jct"
        @method = HttpMethod::POST
        @params = {
          # トークン値	TOKEN_KEY
          # 金融ID	FNC_ID
          # 照会開始日	STARTDATE
          # 照会終了日	ENDDATE
          # 追加認証回答	RESPONSE
          # 要求番号	SS_SYS_NO
          # 一連番号	TR_SEQ
          # 追加認証タイプ	QUERYTYPE
          "TOKEN_KEY" => params[:token],
          "FNC_ID" => params[:fnc_id],
        }
      end
    end

    # 金融機関削除
    class DeleteAccount < AtAPIRequest::Request
      def initialize(params)
        @path = "/openfincd001.jct"
        @method = HttpMethod::GET
        @params = {
            "TOKEN_KEY" => params[:token],
            "FNC_ID" => params[:fnc_id]
        }
      end
    end

    # ATのユーザーアカウント削除（退会）
    class DeleteAtUser < AtAPIRequest::Request
      def initialize(params)
        @path = "/openuserd002.jct"
        @method = HttpMethod::GET
        @params = {
            "TOKEN_KEY" => params[:token]
        }
      end
    end

  end
end
