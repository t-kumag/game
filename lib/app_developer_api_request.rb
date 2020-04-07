module AppDeveloperAPIRequest
  module HttpMethod
    GET = "get".freeze
    POST = "post".freeze
  end
  class Request
    attr_reader :params, :url, :method
  end

  module AppStore
    class ReceiptVerification < AppDeveloperAPIRequest::Request
      def initialize(params)
        @url = Settings.app_store_receipt_verification_url
        @method = HttpMethod::POST
        @params = {
          "receipt-data" => params['receipt_data'],
          "password" => Settings.app_store_secret,
          "exclude-old-transactions" => true
        }
      end
    end
  end

  module GooglePlay
    class ReceiptVerification < AppDeveloperAPIRequest::Request
      def initialize(params)
        @url = "https://www.googleapis.com/androidpublisher/v3/applications/inc.osidori/purchases/subscriptions/#{params['product_id']}/tokens/#{params['purchase_token']}"
        @method = HttpMethod::GET
        @params = {
          "access_token" => params['access_token'],
        }
      end
    end

    class GeAccessToken < AppDeveloperAPIRequest::Request
      def initialize
        @url = "https://accounts.google.com/o/oauth2/token"
        @method = HttpMethod::POST
        @params = {
          "grant_type" => "refresh_token",
          "client_id" => Settings.google_play_client_id,
          "client_secret" => Settings.google_play_client_secret,
          "refresh_token" => Settings.google_play_refresh_token
        }
      end
    end

  end
end
