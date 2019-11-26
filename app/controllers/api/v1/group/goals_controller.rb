class Api::V1::Group::GoalsController < ApplicationController
  before_action :authenticate, :require_group
  before_action :require_group, except: [:graph]

  def index
    goals = Entities::Goal.where(group_id: @current_user.group_id)
    @responses = Services::GoalService.new(@current_user).goal_list(goals) if goals.present?
    render(json: {}, status: 200) and return if @responses.blank?
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
    if disallowed_goal_ids?([params[:id].to_i], true)
      render_disallowed_goal_ids && return
    end

    @response = Services::GoalService.new(@current_user).get_goal_one(params[:id])
    render(json: { errors: { code: '', mesasge: "Record not found." } }, status: 422) and return if @response.blank?

    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def create
    if get_goal_setting_params[:at_user_bank_account_id].present? &&
        disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]], true)
      return render_disallowed_financier_ids
    end

    unless Services::GoalService.check_goal_limit_of_free_user(@current_user)
      return render json: { errors: { code: '', message: "five goal limit of free users" } }, status: 422
    end

    goal_params = get_goal_params
    begin
      goal_type = Entities::GoalType.find(goal_params[:goal_type_id]) unless goal_params[:goal_type_id].nil?
      ActiveRecord::Base.transaction do
        goal_params[:name] = goal_type[:name] if goal_params[:name].blank?
        goal_params[:img_url] = goal_type[:img_url] if goal_params[:img_url].blank?
        goal = Entities::Goal.create!(goal_params)
        # 自分の目標設定を登録
        goal.goal_settings.create!(get_goal_setting_params)
        # 相手の目標設定を登録
        goal.goal_settings.create!(get_partner_goal_setting_params)
        # 頭金を入金する際に必要
        goal_service = Services::GoalService.new(@current_user)
        options = create_activity_options(goal)
        create_goal_activity_log(options)

        # 目標ログの登録
        goal.goal_settings.each do |gs|
          goal_service.add_first_amount(goal, gs, gs.first_amount) if gs.at_user_bank_account_id.present?
        end
        create_goal_finished_activity_log(options) if is_checked_exceed_update_goal_amount?(goal)
      end

    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def update
    if disallowed_goal_ids?([params[:id].to_i], true)
      render_disallowed_goal_ids && return
    end

    if disallowed_goal_setting_ids?(params[:id], [params[:goal_settings][:goal_setting_id]], true)
      render_disallowed_goal_setting_ids && return
    end

    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    render json: { errors: { code: '', mesasge: "Goal not found." } }, status: 422 and return if goal.blank?
    goal_setting = Entities::GoalSetting.find_by(id: params[:goal_settings][:goal_setting_id])
    partner_goal_setting = Entities::GoalSetting.find_by(id: params[:partner_goal_settings][:goal_setting_id])

    if goal_setting.blank? || partner_goal_setting.blank?
      render json: { errors: { code: '', mesasge: "Goal settings not found." } }, status: 422 and return
    end

    # 頭金を入金する際に必要
    goal_service = Services::GoalService.new(@current_user)

    begin
      ActiveRecord::Base.transaction do
        exceed_goal_amount = is_checked_exceed_goal_amount?(goal)
        goal.update!(get_goal_params(false))
        goal_setting.update!(get_goal_setting_params)
        partner_goal_setting.update!(get_partner_goal_setting_params)
        options = create_activity_options(goal)
        update_goal_activity_log(options)
        unless Services::GoalLogService.alreday_exist_first_amount(params[:id], @current_user.id)
          goal_service.add_first_amount(goal, goal_setting, goal_setting.first_amount) if goal_setting.at_user_bank_account_id.present?
        end
        create_goal_finished_activity_log(options) if exceed_goal_amount && is_checked_exceed_update_goal_amount?(goal)
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def destroy
    if disallowed_goal_ids?([params[:id].to_i], true)
      render_disallowed_goal_ids && return
    end

    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    if goal.blank?
      render json: { errors: { code: '', mesasge: "Goal not found." } }, status: 422 and return
    end
    begin
      goal.destroy
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def graph
    return render_404 if params[:id].blank?
    if disallowed_goal_ids?([params[:id].to_i], true)
      render_disallowed_goal_ids && return
    end

    @responses = Services::GoalGraphService.new(@current_user, Entities::Goal.find(params[:id]), params[:span]).call
    render 'graph', formats: 'json', handlers: 'jbuilder'
  end

  def add_money
    if disallowed_goal_ids?([params[:id].to_i], true)
      render_disallowed_goal_ids && return
    end

    user_banks = @current_user.try(:at_user).try(:at_user_bank_accounts).pluck(:id)
    partner_at_user_id =  @current_user.try(:partner_user).try(:at_user).try(:id)

    if partner_at_user_id.present?
      user_banks << Entities::AtUserBankAccount.where(at_user_id: partner_at_user_id, share: true).pluck(:id)
      user_banks.flatten!
    end

    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    goal_setting = goal.goal_settings.find_by(at_user_bank_account_id: user_banks, user_id: @current_user.id)

    if user_banks.blank? || goal.blank? || goal_setting.blank?
      render(json: {errors: [{code:"", message:"user not found or goal not found"}]}, status: 422) && return
    end
    
    goal_service = Services::GoalService.new(@current_user)
    if goal_service.check_bank_balance(params[:add_amount], goal_setting)
      # goalの追加入金前の現在の貯金額と目標貯金額の状況をチェック
      exceed_goal_amount = is_checked_exceed_goal_amount?(goal)
      goal_service.add_money(goal, goal_setting, params[:add_amount])
      options = create_activity_options(goal)

      Services::ActivityService.create_activity(@current_user.id, @current_user.group_id, Time.zone.now, :goal_add_money, options)
      Services::ActivityService.create_activity(@current_user.partner_user.id, @current_user.group_id, Time.zone.now, :goal_add_money, options)

      # 更新前の目標貯金額が溜まっていた場合は、既にアクテビティログがあるのでログ出力は不要
      # 更新前の目標貯金額が溜まっていない + 更新後に目標金額に到達した ->このケースのみログを書き込む
      if exceed_goal_amount && is_checked_exceed_update_goal_amount?(goal)
        create_goal_finished_activity_log(options)
      end

      render(json: {}, status: 200)
    else
      render(json: {errors: [{code:"", message:"minus balance"}]}, status: 422)
    end
  end

  private

  def get_goal_setting_params
    params.require(:goal_settings).permit(
      :at_user_bank_account_id,
      :monthly_amount,
      :first_amount
    ).merge(user_id: @current_user.id)
  end

  def get_partner_goal_setting_params
    params.require(:partner_goal_settings).permit(
      :at_user_bank_account_id,
      :monthly_amount,
      :first_amount
    ).merge(user_id: @current_user.partner_user.id)
  end

  def goal_params_merge(goal_params)
    goal_params.merge(group_id: @current_user.group_id, user_id: @current_user.id)
  end

  def get_goal_params(merge=true)
    goal = params.require(:goals).permit(
        :name,
        :img_url,
        :goal_type_id,
        :start_date,
        :end_date,
        :goal_amount
    )
    return goal_params_merge(goal) if merge
    goal
  end

  private

  def create_goal_activity_log(options)
    Services::ActivityService.create_activity(@current_user.id, @current_user.group_id, Time.zone.now, :goal_created, options)
    Services::ActivityService.create_activity(@current_user.partner_user.id, @current_user.group_id, Time.zone.now, :goal_created_partner, options)
  end

  def update_goal_activity_log(options)
    Services::ActivityService.create_activity(@current_user.id, @current_user.group_id, Time.zone.now, :goal_updated, options)
    Services::ActivityService.create_activity(@current_user.partner_user.id, @current_user.group_id, Time.zone.now, :goal_updated, options)
  end

  def create_goal_finished_activity_log(options)
    Services::ActivityService.create_activity(@current_user.id, @current_user.group_id, Time.now, :goal_finished, options)
    Services::ActivityService.create_activity(@current_user.partner_user.i, @current_user.group_id, Time.now, :goal_finished, options)
  end

  def create_activity_options(goal)
    options = {}
    options[:goal] = goal
    options[:transaction] = nil
    options
  end

  # (目標の現在貯金額 >= 目標貯金額金額) == false
  # 現在の目標貯金額が目標金額に到達していなければtrueを返す
  #   -> 既に全体目標金額に現在の目標が到達していたら、その地点でアクティビティログが出力されてるため
  def is_checked_exceed_goal_amount?(goal)
    (goal.current_amount >= goal.goal_amount) == false
  end

  # goalの追加入金後の現在の貯金額と目標貯金額の状況をチェック
  # (目標の現在貯金更新額 >= 目標金額) == true
  # 目標貯金更新額が目標貯金に到達したらtrueを返す
  def is_checked_exceed_update_goal_amount?(goal)
    (goal.current_amount >= goal.goal_amount) == true
  end
end
