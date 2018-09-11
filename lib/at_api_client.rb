class AtAPIClient
  def initialize(requester)
    @requester = requester
  end

  def request
    case @requester.method
    when AtAPIRequest::HttpMethod::POST
      return post
    when AtAPIRequest::HttpMethod::GET
      return get
    else
      # TODO
      # raise error
    end
  end

  private

  def connection
    @connection unless @connection.nil?
    _connection = Faraday::Connection.new(:url => @requester.url) do |builder|
      builder.request :url_encoded # リクエストパラメータを URL エンコードする
      # builder.request :basic_auth, "AUTH_MAIL", "AUTH_PASS"
      builder.response :logger # リクエストを標準出力に出力する
      builder.adapter :net_http # Net/HTTP をアダプターに使う
      #builder.request :retry, max: 10, interval: 0.01 #リトライする場合
    end
    @connection = _connection
    return @connection
  end

  def validate_http_response_status(response)
    case response.status
    when 400
      raise BadRequest, response.body # body に十分な情報が入っているとする
    when 404
      raise NotFound, response.body
    when 500..599
      raise ServerError, response.body
    end
  end

  def post
    response = nil
    begin
      response = connection.post do |req|
        req.url @requester.path
        req.headers["Content-Type"] = "application/json"
        req.body = JSON.pretty_generate(@requester.params)
      end
      validate_http_response_status(response)
    rescue Faraday::Error::TimeoutError => e
      raise Timeout, e.message
    rescue Faraday::Error::ClientError => e # ConnectionFailed でもいいが、親クラスである ClientError で全部拾ってしまう
      raise ServerError, e.message # 500系と混ざってしまうので、もうちょい情報増やすか例外分けてもいいかも
    end
    return json_from(response.body)
  end

  def get
    response = nil
    begin
      response = connection.get do |req|
        req.url @requester.path
        req.params = @requester.params
      end
      validate_http_response_status(response)
    rescue Faraday::Error::TimeoutError => e
      raise Timeout, e.message
    rescue Faraday::Error::ClientError => e # ConnectionFailed でもいいが、親クラスである ClientError で全部拾ってしまう
      raise ServerError, e.message # 500系と混ざってしまうので、もうちょい情報増やすか例外分けてもいいかも
    end
    return json_from(response.body)
  end

  def json_from(text)
    j = JSON.load(text)
    if j["RSLT_CD"] != AtAPIStandardError::SUCCESS
      raise AtAPIStandardError.new(j["RSLT_CD"], j["RSLT_MSG"])
    end
    return j
  end
end
