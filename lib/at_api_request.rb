module AtAPIRequest
  module HttpMethod
    GET = "get"
    POST = "post"
  end

  class Request
    # envに移す
    PWD_SALT = "osdrdev".freeze
    ACCOUNT_NAME_PREFIX = "osdrdev".freeze
    CHNL_ID = "CHNL_OSIDORI".freeze
    URL = "https://atdev.369webcash.com".freeze
    attr_reader :path, :params, :url, :method

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
        # email = "#{ACCOUNT_NAME_PREFIX}-#{user_id}@osdr.dev.co"
        # pwd = Digest::MD5.hexdigest("#{PWD_SALT}#{user_id}") # 保存するのでrandとsaltで良いかも
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

    # params = {
    #   at_user_id: "",
    #   at_user_password: "",
    # }
    class GetToken
      def initialize(params)
        @path = "/opentoknr001.jct"
        @method = HttpMethod::GET
        at_user_id = "#{ACCOUNT_NAME_PREFIX}_#{params[:at_user_id]}"
        @params = {
          "CHNL_ID" => AtAPIRequest::Request::CHNL_ID,
          "USER_ID" => at_user_id,
          # "USER_PW" => params[:at_user_password],
        }
      end
    end

    # 有効な場合は有効期限が延長される
    class GetTokenStatus
      def initialize(params)
        @path = "/opentoknr002.jct"
        @method = HttpMethod::GET
        @params = {
          "CHNL_ID" => AtAPIRequest::Request::CHNL_ID,
          "USER_ID" => params[:at_user_id],
          "TOKEN_KEY" => params[:at_user_token],
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

        # 金融機関区分	FNC_TYPE	半角英	2 			"未入力時 AL 処理
        # AL : 全て, JD : 電子マネー"
        # fnc_type = params[:fnc_type] if params.has_key?(:fnc_type) || !params[:fnc_type].blank?
        @params = {
          "TOKEN_KEY" => params[:token], 
          # "FNC_TYPE" => fnc_type,
        }
      end
    end

    class GetTransaction < AtAPIRequest::Request
      def initialize(params)
        @path = "/openscher002.jct"
        @method = HttpMethod::GET
        @params = {
          "TOKEN_KEY" => params[:token],
          "FNC_ID" => params[:fnc_id],
          "START_DATE" => params[:start_date], # ‘YYYYMMDD’
          "END_DATE" => params[:end_date], # ‘YYYYMMDD’
        }
        @params["CONFIRM_TYPE"] = params[:confirm_type] if params.has_key?(:confirm_type) || !params[:confirm_type].blank?
      end
    end
  end
end
