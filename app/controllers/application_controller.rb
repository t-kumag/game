class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  skip_before_action :verify_authenticity_token, if: :json_request? 

  # before_filter :set_api_version

  # 例外ハンドル
  # unless Rails.env.development?
  #     rescue_from ActiveRecord::RecordNotFound, with: :render_404
  #     rescue_from ActionController::RoutingError, with: :render_404
  #     rescue_from ActionView::MissingTemplate, with: :render_404
  #     rescue_from Exception, with: :render_500
  # end

  # def set_api_version
  #     @api_version = request.path_info[5,2]
  # end

  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  # def append_info_to_payload(payload)
  #   super
  #   payload[:user_id] = current_user.try(:id).try(:presence)
  #   payload[:user_agent] = request.env['HTTP_USER_AGENT']
  #   payload[:remote_host] = request.remote_host
  #   payload[:remote_ip] = request.remote_ip
  #   payload[:remote_user] = request.remote_user
  #   payload[:referer] = request.referer
  # end

  def render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.message}" if e

    if request.xhr?
    render json: { error: '404 error' }, status: 404 and return
    else
    format = params[:format] == :json ? :json : :html
    render template: 'errors/error_404', formats: format, status: 404, layout: 'application', content_type: 'text/html'
    end
  end

  def render_500(e = nil)
    logger.error e.message + "\n" + e.backtrace.join("\n")
    ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "[#{Rails.env}]" + e.message + "::" + e.backtrace[0..50].join("::") + " ..."})
    #Airbrake.notify(e) if e # Airbrake/Errbitを使う場合はこちら

    logger.info "Rendering 500 with exception: #{e.message}" if e
    if request.xhr?
      render json: { error: '500 error' }, status: 500 and return
    else
      format = params[:format] == :json ? :json : :html
      render template: 'errors/error_500', formats: format, status: 500, layout: 'application', content_type: 'text/html'
    end
  end

  private
  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    @current_user = Entities::User.find_by_token(bearer_token)
    return false if @current_user.nil?
    return true
  end

  def render_unauthorized
    # render_errors(:unauthorized, ['invalid token'])
    obj = { meta: {error: 'token invalid' }}    
    render json: obj, status: :unauthorized
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  def json_request?
    request.format.json?
  end
end