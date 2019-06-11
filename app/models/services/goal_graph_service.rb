class Services::GoalGraphService
  def initialize(user, goal, span)
    @user = user
    @goal = goal
    @span = span
  end

  # 各月の達成値 月の入金額 / 月の目標金額
  def do
    goal_logs = {}
    return {} if @span.blank?
    if @span.to_i > 0
      goal_logs = Entities::GoalLog.where(add_date: (span_date)..(Time.zone.today.beginning_of_month))
    elsif @span == 'all'
      goal_logs = @goal.goal_logs
    end
    {} unless goal_logs
    format = format(goal_logs)
    aggregate(format, goal_logs)
  end

  private

  def span_date
    @span.to_i.month.ago
  end

  # 目標期間から月数を計算
  def goal_span_to_count
    (@goal.end_date.year * 12 + @goal.end_date.month) - (@goal.start_date.year * 12 + @goal.start_date.month) + 1
  end

  # 月の目標を計算
  def monthly_goal_amount
    @goal.goal_amount / goal_span_to_count
  end

  # 月の達成値
  def monthly_progress(amount, goal_amount)
    amount.to_f / goal_amount.to_f
  end

  # 月の入金を計算
  def sum_amount(goal_log)
    goal_log.add_amount + goal_log.monthly_amount + goal_log.first_amount
  end

  # アウトプットのフォーマットを生成
  def format(goal_logs)
    result = {}
    keys = goal_logs.pluck(:add_date).uniq.sort
    keys.each do |k|
      result.store(
        k.strftime('%Y-%m-%d'),
        'goal_amount' => 0,
        'amount' => 0,
        'progress' => 0
      )
    end
    result
  end

  # フォーマットに値をセット
  def aggregate(format, goal_logs)
    # amount
    goal_logs.each do |gl|
      format[gl.add_date.strftime('%Y-%m-%d')]['goal_amount'] = monthly_goal_amount
      format[gl.add_date.strftime('%Y-%m-%d')]['amount'] += sum_amount(gl)
    end

    # progress
    format.each do |f|
      f[1]['progress'] = monthly_progress(f[1]['amount'], f[1]['goal_amount'])
    end

    format
  end
end
