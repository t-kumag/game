class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  skip_before_action :verify_authenticity_token, if: :json_request?

  # before_filter :set_api_version

  # 例外ハンドル
  rescue_from ActiveRecord::RecordNotFound, with: :render_422
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from AtAPIStandardError, with: :render_at_api_error
  rescue_from ActionController::RoutingError, with: :render_404
  #     rescue_from ActionView::MissingTemplate, with: :render_404
  #     rescue_from Exception, with: :render_500


  # def set_api_version
  #     @api_version = request.path_info[5,2]
  # end

  def routing_error
    fail ActionController::RoutingError.new(params[:path])
  end

  def render_record_invalid(e = nil)
    @errors = []
    resource_name = e.record.class.to_s.split('::').last
    e.record.errors.details.each do |key, detail|
      detail.each do |value|
        @errors << {
          resource: resource_name,
          field: key,
          code: value[:error]
        }
      end
    end
    render('api/v1/errors/record_invalid', formats: 'json', handlers: 'jbuilder', status: 400) && return
  end

  def render_400_invalid_validation(e=[])
    errors = e.map do |error|
      {
        "resource": error[:resource],
        "field": error[:field],
        "code": error[:code]
      }
    end

    render json: {errors: errors}, status: 400
  end

  def render_at_api_error(e = nil)
    @errors = [
      {
        code: e.code,
        message: e.message
      }
    ]
    render('api/v1/errors/at_api_error', formats: 'json', handlers: 'jbuilder', status: 200) && return
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

    render(json: { error: '404 error' }, status: 404) && return
    # if request.xhr?
    # render json: { error: '404 error' }, status: 404 and return
    # else
    # format = params[:format] == :json ? :json : :html
    # render template: 'errors/error_404', formats: format, status: 404, layout: 'application', content_type: 'text/html'
    # end
  end

  def render_422
    render json: {errors: [{code: "message sample fobidden"}]}, status: 422 && return
  end

  def render_500(e = nil)
    logger.error e.message + "\n" + e.backtrace.join("\n")
    ExceptionNotifier.notify_exception(e, env: request.env, data: { message: "[#{Rails.env}]" + e.message + '::' + e.backtrace[0..50].join('::') + ' ...' })
    # Airbrake.notify(e) if e # Airbrake/Errbitを使う場合はこちら

    logger.info "Rendering 500 with exception: #{e.message}" if e
    render(json: { error: '500 error' }, status: 500) && return
    # if request.xhr?
    #   render json: { error: '500 error' }, status: 500 and return
    # else
    #   format = params[:format] == :json ? :json : :html
    #   render template: 'errors/error_500', formats: format, status: 500, layout: 'application', content_type: 'text/html'
    # end
  end

  private

  def authenticate
    return render_unauthorized unless authenticate_token
    activated?
  end

  # def token_authenticate
  #   authenticate_or_request_with_http_token do |token, options|
  #     @user = User.token_authenticate!(token)
  #     @user && DateTime.now <= @user.token_expire
  #   end
  # end

  def activated?
    return if @current_user.try(:email_authenticated)
    render_forbidden
  end

  def authenticate_token
    @current_user = Entities::User.token_authenticate!(bearer_token)
    @current_user && DateTime.now <= @current_user.token_expires_at
  end

  def render_forbidden
    render json: {}, status: :forbidden
  end

  def render_unauthorized
    # render_errors(:unauthorized, ['invalid token'])
    obj = {}
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

  def check_temporary_user
    @response = Entities::User.temporary_user(params[:email])
    if @response.present?
      render 'api/v1/errors/temporary_registration', formats: 'json', handlers: 'jbuilder', status: 422
    end
  end

  # 参照可能な口座ID
  # cardやemoneyも同様の処理が必要な場合はサービスに移行する
  def disallowed_at_bank_ids?(bank_ids, with_group=false)
    at_user_id         =  @current_user.try(:at_user).try(:id)
    partner_at_user_id =  @current_user.try(:partner_user).try(:at_user).try(:id)

    at_user_bank_ids = Entities::AtUserBankAccount.where(at_user_id: at_user_id).pluck(:id)
    if partner_at_user_id && with_group
      at_user_bank_ids << Entities::AtUserBankAccount.where(at_user_id: partner_at_user_id, share: true).pluck(:id)
    end
    at_user_bank_ids.flatten!

    bank_ids.each do |id|
      return true unless at_user_bank_ids.include?(id)
    end
    false
  end

  def disallowed_at_card_ids?(card_ids, with_group=false)
    at_user_id         =  @current_user.try(:at_user).try(:id)
    partner_at_user_id =  @current_user.try(:partner_user).try(:at_user).try(:id)

    at_user_card_ids = Entities::AtUserCardAccount.where(at_user_id: at_user_id).pluck(:id)
    if partner_at_user_id && with_group
      at_user_card_ids << Entities::AtUserCardAccount.where(at_user_id: partner_at_user_id, share: true).pluck(:id)
    end
    at_user_card_ids.flatten!

    card_ids.each do |id|
      return true unless at_user_card_ids.include?(id)
    end
    false
  end

  def disallowed_at_emoney_ids?(emoney_ids, with_group=false)
    at_user_id         =  @current_user.try(:at_user).try(:id)
    partner_at_user_id =  @current_user.try(:partner_user).try(:at_user).try(:id)

    at_user_emoney_ids = Entities::AtUserEmoneyServiceAccount.where(at_user_id: at_user_id).pluck(:id)
    if partner_at_user_id && with_group
      at_user_emoney_ids << Entities::AtUserEmoneyServiceAccount.where(at_user_id: partner_at_user_id, share: true).pluck(:id)
    end
    at_user_emoney_ids.flatten!

    emoney_ids.each do |id|
      return true unless at_user_emoney_ids.include?(id)
    end
    false
  end

  def disallowed_at_bank_transaction_ids?(bank_id, bank_transaction_ids, with_group=false)
    user_bank = @current_user.try(:at_user).try(:at_user_bank_accounts).try(:find_by, id: bank_id)
    at_user_bank_transaction_ids = []
    at_user_bank_transaction_ids << user_bank.try(:at_user_bank_transactions).pluck(:id) if user_bank.try(:at_user_bank_transactions).present?

    if with_group
      partner_bank = @current_user.try(:partner_user).try(:at_user).try(:at_user_bank_accounts).try(:find_by, id: bank_id)
      at_user_bank_transaction_ids << partner_bank.try(:at_user_bank_transactions).pluck(:id) if partner_bank.try(:at_user_bank_transactions).present?
    end

    return true if at_user_bank_transaction_ids.blank?
    at_user_bank_transaction_ids.flatten!
    
    bank_transaction_ids.each do |id|
      # 自身の明細以外のidの場合、参照不可できない（groupの場合、パートナーの明細も含む）
      return true unless at_user_bank_transaction_ids.include?(id)

      next unless with_group
      transaction = Entities::AtUserBankTransaction.find(id)
      next if transaction.try(:user_distributed_transaction).try(:share) || transaction.try(:at_user_bank_account).try(:share)
      return true
    end
    false
  end

  def disallowed_at_card_transaction_ids?(card_id, card_transaction_ids, with_group=false)
    user_card = @current_user.try(:at_user).try(:at_user_card_accounts).try(:find_by, id: card_id)
    at_user_card_transaction_ids = []
    at_user_card_transaction_ids << user_card.try(:at_user_card_transactions).pluck(:id) if user_card.try(:at_user_card_transactions).present?

    if with_group
      partner_card = @current_user.try(:partner_user).try(:at_user).try(:at_user_card_accounts).try(:find_by, id: card_id)
      at_user_card_transaction_ids << partner_card.try(:at_user_card_transactions).pluck(:id) if partner_card.try(:at_user_card_transactions).present?
    end
    return true if at_user_card_transaction_ids.blank?
    at_user_card_transaction_ids.flatten!

    card_transaction_ids.each do |id|
      # 自身の明細以外のidの場合、参照不可できない（groupの場合、パートナーの明細も含む）
      return true unless at_user_card_transaction_ids.include?(id)

      next unless with_group
      transaction = Entities::AtUserCardTransaction.find(id)
      next if transaction.try(:user_distributed_transaction).try(:share) || transaction.try(:at_user_card_account).try(:share)
      return true
    end
    false
  end

  def disallowed_at_emoney_transaction_ids?(emoney_id, emoney_transaction_ids, with_group=false)
    user_emoney = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:find_by, id: emoney_id)
    at_user_emoney_transaction_ids = []
    at_user_emoney_transaction_ids << user_emoney.try(:at_user_emoney_transactions).pluck(:id) if user_emoney.try(:at_user_emoney_transactions).present?

    if with_group
      partner_emoney = @current_user.try(:partner_user).try(:at_user).try(:at_user_emoney_service_accounts).try(:find_by, id: emoney_id)
      at_user_emoney_transaction_ids << partner_emoney.try(:at_user_emoney_transactions).pluck(:id) if partner_emoney.try(:at_user_emoney_transactions).present?
    end
    return true if at_user_emoney_transaction_ids.blank?
    at_user_emoney_transaction_ids.flatten!

    emoney_transaction_ids.each do |id|
      # 自身の明細以外のidの場合、参照不可できない（groupの場合、パートナーの明細も含む）
      return true unless at_user_emoney_transaction_ids.include?(id)

      next unless with_group
      transaction = Entities::AtUserEmoneyTransaction.find(id)
      next if transaction.try(:user_distributed_transaction).try(:share) || transaction.try(:at_user_emoney_service_account).try(:share)
      return true
    end
    false
  end

  def disallowed_manually_created_transaction_ids?(manually_created_transaction_ids, with_group=false)
    user_id = @current_user.id
    partner_user_id = @current_user.try(:partner_user).try(:id)

    user_manually_created_transaction_ids = Entities::UserManuallyCreatedTransaction.where(user_id: user_id).pluck(:id)
    if partner_user_id && with_group
      user_manually_created_transaction_ids << Entities::UserManuallyCreatedTransaction.where(user_id: partner_user_id).pluck(:id)
    end
    user_manually_created_transaction_ids.flatten!
    
    manually_created_transaction_ids.each do |id|
      # 自身の明細以外のidの場合、参照不可できない（groupの場合、パートナーの明細も含む）
      return true unless user_manually_created_transaction_ids.include?(id)
      next unless with_group
      transaction = Entities::UserManuallyCreatedTransaction.find(id)
      next if transaction.try(:user_distributed_transaction).try(:share)
      return true
    end
    false
  end

  def disallowed_goal_ids?(goal_ids, with_group=false)
    user_id = @current_user.id
    partner_user_id = @current_user.try(:partner_user).try(:id)

    user_goal_ids = Entities::Goal.where(user_id: user_id).pluck(:id)

    user_goal_ids << Entities::Goal.where(user_id: partner_user_id).pluck(:id) if partner_user_id && with_group
    user_goal_ids.flatten!

    goal_ids.each do |id|
      return true unless user_goal_ids.include?(id)
    end
    false
  end

  def disallowed_goal_setting_ids?(goal_id, goal_setting_ids, with_group=false)
    user_id = @current_user.id
    partner_user_id = @current_user.try(:partner_user).try(:id)

    user_goal_setting_ids = Entities::GoalSetting.where(goal_id: goal_id, user_id: user_id).pluck(:id)
    if partner_user_id && with_group
      user_goal_setting_ids << Entities::GoalSetting.where(goal_id: goal_id, user_id: partner_user_id).pluck(:id)
    end
    user_goal_setting_ids.flatten!

    goal_setting_ids.each do |id|
      return true unless user_goal_setting_ids.include?(id)
    end
    false
  end

  def require_group
    render json: { errors: { code: '', message: "Require group." } }, status: 422 unless @current_user.group_id.present?
  end

  def render_disallowed_financier_ids
    render json: { errors: { code: '003001', message: "Disallowed financier id." } }, status: 422
  end

  def render_disallowed_transaction_ids
    render json: { errors: { code: '', message: "Disallowed transaction id." } }, status: 422
  end

  def render_disallowed_goal_ids
    render json: { errors: { code: '', message: "Disallowed goal id." } }, status: 422
  end

  def render_disallowed_goal_setting_ids
    render json: { errors: { code: '', message: "Disallowed goal setting id." } }, status: 422
  end
end
