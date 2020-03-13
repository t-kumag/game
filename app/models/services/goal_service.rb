class Services::GoalService

  def initialize(user)
    @user = user
  end

  def goal_amount(account_ids)
    amount = 0
    Entities::GoalLog.where(at_user_bank_account_id: account_ids).each do |gl|
      amount += gl.add_amount + gl.monthly_amount + gl.first_amount
    end
    amount
  end

  def goal_list(goals)
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

  def get_goal_one(id)
    goal = Entities::Goal.find_by(id: id, group_id: @user.group_id)
    return {} if goal.blank?

    users = {}

    users[:owner] = @user
    users[:partner] = @user.partner_user

    owner_current_amount = get_user_current_amount(users[:owner], goal.id)
    partner_current_amount = get_user_current_amount(users[:partner], goal.id)

    {
        goal_id: goal.id,
        goal_type_id: goal.goal_type_id,
        name: goal.name,
        img_url: goal.img_url,
        goal_amount: goal.goal_amount,
        current_amount: goal.current_amount,
        start_date: goal.start_date,
        end_date: goal.end_date,
        progress_all: progress_all(goal.current_amount,  goal.goal_amount),
        progress_monthly: progress_monthly(goal),
        owner_current_amount: owner_current_amount,
        partner_current_amount: partner_current_amount,
        goal_settings: goal.goal_settings
    }
  end

  def self.get_goal(goal, goal_setting)
    {
        id: goal.id,
        goal_type_id: goal.goal_type_id,
        group_id: goal.group_id,
        user_id: goal.user_id,
        name: goal.name,
        img_url: goal.img_url,
        goal_amount: goal.goal_amount,
        current_amount: goal.current_amount + goal_setting.monthly_amount
    }
  end

  def self.update_goal_plus_current_amount(goal, goal_setting, old_goal_log)
    {
        id: goal[:id],
        goal_type_id: goal[:goal_type_id],
        group_id: goal[:group_id],
        user_id: goal[:user_id],
        name: goal[:name],
        img_url: goal[:img_url],
        goal_amount: goal[:goal_amount],
        current_amount: old_goal_log[:after_current_amount] + goal_setting.monthly_amount
    }
  end

  # TODO: Services::GoalLogService.add_monthly_amount_insertこの処理をcontroller側に回すと効率よくかける
  # TODO: 静的関数にしたほうがいいので、後ほどリファクタリングする
  def self.add_monthly_amount(goal, goal_setting, add_amount)
    begin
      ActiveRecord::Base.transaction do
        Services::GoalLogService.add_monthly_amount_insert(goal, goal_setting)
        goal.current_amount += add_amount
        goal.save!
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
    goal
  end

  # TODO: Services::GoalLogService.add_first_amount_insert(goal, goal_setting)この処理をcontroller側に回すと効率よくかける
  # TODO: 静的関数にしたほうがいいので、後ほどリファクタリングする
  def add_first_amount(goal, goal_setting, add_amount)
    begin
      ActiveRecord::Base.transaction do
        Services::GoalLogService.add_first_amount_insert(goal, goal_setting)
        goal.current_amount += add_amount
        goal.save!
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
  end

  # TODO: Services::GoalLogService.add_amount_insert(goal, goal_setting, add_amount)この処理をcontroller側に回すと効率よくかける
  # TODO: 静的関数にしたほうがいいので、後ほどリファクタリングする
  def add_money(goal, goal_setting, add_amount)
    begin
      ActiveRecord::Base.transaction do
        Services::GoalLogService.add_amount_insert(goal, goal_setting, add_amount)
        goal.current_amount += add_amount
        goal.save!
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
  end

  def self.check_goal_limit_of_free_user(user)
    user.free? && Entities::Goal.where(user_id: user.id).count < Settings.at_user_limit_free_goal
  end

  def self.is_checked_one_account(params)
    params[:at_user_bank_account_id].present? && params[:wallet_id].present?
  end

  def self.setting_params(params)
    params[:wallet_id] = nil if params[:at_user_bank_account_id].present?
    params[:at_user_bank_account_id] = nil if params[:wallet_id].present?
    params
  end

  def goals(finance, with_group=false)
    user_ids = [@user.id]
    user_ids.push(@user.partner_user.id) if with_group && @user.partner_user.try(:id).present?
    goal_settings = Entities::GoalSetting.where(at_user_bank_account_id: finance.id, user_id: user_ids) if finance.instance_of?(Entities::AtUserBankAccount)
    goal_settings = Entities::GoalSetting.where(wallet_id: finance.id, user_id: user_ids) if finance.instance_of?(Entities::Wallet)

    goals = goal_settings.map do |gs|
      # 現状は goal 削除時に goal_settings はそのままのため、ここで除外する
      next if gs.goal.nil?
      user = Entities::User.find(gs.user_id)
      current_amount = get_user_current_amount(user, gs.goal.id)[:current_amount]
      {
        goal_id: gs.goal_id,
        current_amount: current_amount,
        name: gs.goal.name
      }
    end.compact

    if with_group
      after_merge_goals = []
      goals.each do |v|
        g = after_merge_goals.select {|i| i[:goal_id] === v[:goal_id] }.first
        if g.blank?
          after_merge_goals << v
        else
          g[:current_amount] += v[:current_amount]
        end
      end 
    end

    with_group ? after_merge_goals : goals
  end

  def get_user_current_amount(user, goal_id)
    goal_logs = Entities::GoalLog.where(user_id: user.id, goal_id: goal_id)
    monthly_amount = get_monthly_amount_sum(goal_logs)
    first_amount = get_first_amount_sum(goal_logs)
    add_amount = get_add_amount_sum(goal_logs)

    {
        monthly_amount: monthly_amount,
        first_amount: first_amount,
        current_amount: monthly_amount + first_amount + add_amount,  #月々の積立金(monthly_amount) + 初回入金(first_amount) + 追加入金(add_amount)
        add_amount: add_amount
    }
  end

  def progress_all(current_amount, goal_amount)
    calculate_float_result = calculate_float_value_result(current_amount, goal_amount)

    # progress: 現在の貯金額 / 目標の貯金額
    # 切り捨てでの実装はBigDecimalを使用する必要があるために使用している
    { progress: BigDecimal(calculate_float_result).floor(2).to_f }
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

  private

  def get_monthly_amount_sum(goal_logs)
    goal_logs.sum{|i| i.monthly_amount }
  end

  def get_first_amount_sum(goal_logs)
    goal_logs.sum{|i| i.first_amount }
  end

  def get_add_amount_sum(goal_logs)
    goal_logs.sum{|i| i.add_amount }
  end

  def monthly_total_amount(goal)
    this_month_goal_logs = goal.goal_logs.where(add_date: (Time.zone.today.beginning_of_month)...(Time.zone.today.end_of_month))
    #月々の積立金(monthly_amount) + 初回入金(first_amount) + 追加入金(add_amount)
    this_month_goal_logs.sum{|i| i.monthly_amount + i.first_amount + i.add_amount}
  end

  # 何ヶ月分の差があるかを算出するメソッド
  # 月の目標金額を算出するには、開始月と終了月の月数を取得
  def difference_month(goal)
    (goal.end_date.to_time.month + goal.end_date.to_time.year * 12) - (goal.start_date.month + goal.start_date.to_time.year * 12)
  end

  def calculate_float_value_result(amount1, amount2)
    (amount1.to_f / amount2.to_f).to_s
  end

  def monthly_achieving_rate_and_icon(monthly_amount, monthly_goal_amount)
    icon = "normal"
    calculate_float_result = calculate_float_value_result(monthly_amount, monthly_goal_amount)

    # 1ヶ月の進捗状況 =  当月の貯金額 - 目標の貯金額
    # 切り捨てでの実装はBigDecimalを使用する必要があるために使用している
    monthly_achieving_rate = BigDecimal(calculate_float_result).floor(1).to_f
    icon = "best" if BigDecimal(calculate_float_result) > 0

    {
        progress: monthly_achieving_rate,
        icon: icon
    }
  end

end