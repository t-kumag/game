class Api::V1::Group::GoalsController < ApplicationController
  before_action :authenticate, :require_group
  before_action :require_group, except: [:graph]

  def index
    goals = Entities::Goal.where(group_id: @current_user.group_id)
    @responses = get_goal_lists(goals)  if goals.present?
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
        disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]])
      return render_disallowed_financier_ids
    end

    return render json: { errors: { code: '', message: "five goal limit of free users" } }, status: 422  unless Services::GoalService.check_goal_limit_of_free_user(@current_user)

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
      end

      Services::ActivityService.create_user_manually_activity(@current_user.id,
                                                              @current_user.group_id,
                                                              Time.zone.now,
                                                              :goal_created)
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

    if disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]], true)
      return render_disallowed_financier_ids
    end

    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    render json: { errors: { code: '', mesasge: "Goal not found." } }, status: 422 and return if goal.blank?
    goal_setting = Entities::GoalSetting.find_by(id: params[:goal_settings][:goal_setting_id])
    render json: { errors: { code: '', mesasge: "Goal settings not found." } }, status: 422 and return if goal_setting.blank?

    begin
      ActiveRecord::Base.transaction do
        goal.update!(get_goal_params)
        goal_setting.update!(get_goal_setting_params)
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

    current_user_banks = @current_user.at_user.at_user_bank_accounts.pluck(:at_bank_id)
    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    goal_setting = goal.goal_settings.find_by(at_user_bank_account_id: current_user_banks)

    if current_user_banks.blank? || goal.blank? || goal_setting.blank?
      render(json: {errors: [{code:"", message:"user not found or goal not found"}]}, status: 422) && return
    end
    
    goal_service = Services::GoalService.new(@current_user)
    if goal_service.check_bank_balance(params[:add_amount], goal_setting)
      goal_service.add_money(goal, goal_setting, params[:add_amount])
      Services::ActivityService.create_user_manually_activity(@current_user.id,
                                                              @current_user.group_id,
                                                              Time.zone.now,
                                                              :goal_add_money)
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
      :monthly_amount,
      :first_amount
    ).merge(user_id: @current_user.partner_user.id)
  end

  def get_goal_params
    params.require(:goals).permit(
      :name,
      :img_url,
      :goal_type_id,
      :start_date,
      :end_date,
      :goal_amount
    ).merge(group_id: @current_user.group_id, user_id: @current_user.id)
  end

  def get_goal_lists(goals)
    goals = goals.map do |g|
      {
          id: g.id,
          group_id: g.group_id,
          user_id: g.user_id,
          goal_type_id: g.goal_type_id,
          name: g.name,
          img_url: g.img_url,
          start_date: g.start_date,
          end_date: g.end_date,
          goal_amount: g.goal_amount,
          current_amount: g.current_amount,
          progress_all: progress_all(g.current_amount,  g.goal_amount),
          progress_monthly: progress_monthly(g),
          goal_settings: g.goal_settings
      }
    end
    goals
  end

  private
  def progress_all(current_amount, goal_amount)
    calculate_float_result = calculate_float_value_result(current_amount, goal_amount)

    # progress: 現在の貯金額 / 目標の貯金額
    # 切り捨てでの実装はBigDecimalを使用する必要があるために使用している
    { progress: BigDecimal(calculate_float_result).floor(1).to_f }
  end

  def monthly_total_amount(goal)
    this_month_goal_logs = goal.goal_logs.where(add_date: (Time.zone.today.beginning_of_month)...(Time.zone.today.end_of_month))
    #月々の積立金(monthly_amount) + 初回入金(first_amount) + 追加入金(add_amount)
    this_month_goal_logs.sum{|i| i.monthly_amount + i.first_amount + i.add_amount}
  end

  def icon(monthly_achieving_rate)
    return "best" if monthly_achieving_rate >= 0.7
    return "normal" if monthly_achieving_rate >= 0.5
    "bad"
  end

  def monthly_achieving_rate_and_icon(monthly_amount, monthly_goal_amount)
    calculate_float_result = calculate_float_value_result(monthly_amount, monthly_goal_amount)

    # 1ヶ月の進捗状況 =  当月の貯金額 - 目標の貯金額
    # 切り捨てでの実装はBigDecimalを使用する必要があるために使用している
    monthly_achieving_rate = BigDecimal(calculate_float_result).floor(1).to_f
    {
        progress: monthly_achieving_rate,
        icon: icon(monthly_achieving_rate)
    }
  end

  # 何ヶ月分の差があるかを算出するメソッド
  # 月の目標金額を算出するには、開始月と終了月の月数を取得
  def difference_month(goal)
    (goal.end_date.to_time.month + goal.end_date.to_time.year * 12) - (goal.start_date.month + goal.start_date.to_time.year * 12)
  end

  def progress_monthly(goal)
    monthly_amount = monthly_total_amount(goal)
    difference_month = difference_month(goal)
    # 1ヶ月分の目標金額 = 目標金額
    monthly_goal_amount = goal.goal_amount

    # 1ヶ月分の目標金額 = 目標金額 / 目標までの月数
    monthly_goal_amount = goal.goal_amount / difference_month  unless difference_month <= 0
    monthly_achieving_rate_and_icon(monthly_amount, monthly_goal_amount)
  end

  def calculate_float_value_result(amount1, amount2)
    (amount1.to_f / amount2.to_f).to_s
  end

end
