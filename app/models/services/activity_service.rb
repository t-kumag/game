class Services::ActivityService

  def self.make_goal_activity(goal, goal_setting, activity_type)
    defined_activity = ACTIVITY_TYPE::NAME[activity_type]
    activity = set_activity(defined_activity)
    activity = convert_goal_message(goal, defined_activity, activity) if goal.present?
    assign_parameter(goal_setting.user_id, goal.group_id, activity_type, activity)
  end

  def self.assign_parameter(user_id, group_id, activity_type, activity)
    {
        user_id: user_id,
        group_id: group_id,
        url: activity[:url],
        count: 0,
        activity_type: activity_type,
        message: activity[:message],
        date: Time.zone.now
    }
  end

  def self.save_activities(activities)
    Entities::Activity.import activities, :on_duplicate_key_update => [:user_id, :date, :activity_type], :validate => false
  end

  def self.create_activity(user_id, group_id, used_date, activity_type, options={})
    activity = activity_assign_parameter(activity_type, options)
    create_activity_data(user_id, group_id, used_date, activity_type, activity)
  end

  def self.set_activity_list(financier_account_type_key, tran, account, user)
    activity = create_base_activity(user, account)
    activity_data_column = get_activity_data_column(financier_account_type_key)

    activity_data_column.each do |k, v|
      if v[:col] == "USED_DATE" || v[:col] == "TRADE_DTM"
        activity[:date] = tran[k]
      elsif v[:col] == "PAYMENT_AMOUNT" ||  v[:col] == "AMOUNT_RECEIPT"
        activity[:activity_type] = (tran[k].to_i == 0) ? v[:income] : v[:outcome]
        activity[:activity_type] = "individual_card_outcome" if k == :payment_amount
        activity[:message] = (tran[k].to_i == 0) ? v[:income_message] : v[:outcome_message]
        activity[:message] = "クレジットカードの支出があります。" if k == :payment_amount
      end
    end
    activity
  end

  def self.check_activity_duplication(financier_account_type_key, activities, activity)
    latest_one = activities.present? ? activities.last : nil
    return true if latest_one.nil? ? true : false
    activity_data_column = get_activity_data_column(financier_account_type_key)
    check_duplication_old_act(latest_one, activity, activity_data_column)
  end

  def self.fetch_activities(user, page)
    Entities::Activity.where(user_id: user.id).order(created_at: "DESC").page(page)
  end

  def self.fetch_activities_goal_finished
    Entities::Activity.where(activity_type: :goal_finished)
  end

  def self.fetch_activity_type(user, type)
    Entities::Activity.where(user_id: user.id).where(activity_type: type).order(created_at: "DESC").first()
  end

  # TODO v2移行時に削除
  # のちに削除される一時的な処理
  def self.trade_list(user, date=Time.now.strftime("%Y-%m-%d").to_s)
    p_count = Entities::Activity
      .where(user_id: user.id)
      .where("activity_type LIKE ?", 'individual%')
      .where("created_at >= ?", date)
      .count

    f_count = Entities::Activity
      .where(user_id: user.id)
      .where("activity_type LIKE ?", 'partner%')
      .where("created_at >= ?", date)
      .count

    [p_count, f_count]
  end

  # TODO v2移行時に削除
  # のちに削除される一時的な処理
  # アクティビティから個人と家族の取引をカウントする
  def self.save_trade_count(user, date=Time.now.strftime("%Y-%m-%d").to_s)
    nums = trade_list(user)

    # message生成 個人の取引がn件ありました。 person_expense_income
    # ここから
    p_activity = Entities::Activity
      .where(user_id: user.id)
      .where("activity_type LIKE ?", 'person_expense_income')
      .where("created_at >= ?", date)
      .first

    if p_activity.present? && nums[0] > 0
      begin
        p_activity.update_attributes(
            count: nums[0],
            message: sprintf(ACTIVITY_TYPE::NAME[:person_expense_income][:message], nums[0])
        )
      rescue => e
        # 処理を中断させない。
      end
    end

    if p_activity.blank? && nums[0] > 0
      set_activity = set_activity(ACTIVITY_TYPE::NAME[:person_expense_income])
      set_activity[:message] = sprintf(ACTIVITY_TYPE::NAME[:person_expense_income][:message], nums[0])
      set_activity[:count] = nums[0]
      create_activity_data(user.id, nil, date, 'person_expense_income', set_activity)
    end

    # message生成 家族の取引がn件ありました。familly_expense_income
    # ここから
    f_activity = Entities::Activity
                     .where(user_id: user.id)
                     .where("activity_type LIKE ?", 'familly_expense_income')
                     .where("created_at >= ?", date)
                     .first

    if f_activity.present? && nums[1] > 0
      begin
        f_activity.update_attributes(
            count: nums[1],
            message: sprintf(ACTIVITY_TYPE::NAME[:familly_expense_income][:message], nums[1])
        )
      rescue => e
        # 処理を中断させない。
      end
    end

    if f_activity.blank? && nums[1] > 0
      set_activity = set_activity(ACTIVITY_TYPE::NAME[:familly_expense_income])
      set_activity[:message] = sprintf(ACTIVITY_TYPE::NAME[:familly_expense_income][:message], nums[1])
      set_activity[:count] = nums[1]
      create_activity_data(user.id, user.group_id, date, 'familly_expense_income', set_activity)
    end
  end

  private
  def self.get_activity_data_column(financier_account_type_key)
    case financier_account_type_key
    when "at_user_card_account_id"
      get_card_activity_data_column
    when "at_user_bank_account_id"
      get_bank_activity_data_column
    when "at_user_emoney_service_account_id"
      get_emoney_activity_data_column
    end
  end

  def self.check_duplication_old_act(latest_one, activity, activity_data_column)
    src_insert = { date: false, activity: false }
    activity_data_column.each do |k, v|
      if v[:col] == "USED_DATE" || v[:col] == "TRADE_DTM"
        src_insert[:date] = activity[:date] == latest_one[:date]
      elsif v[:col] == "PAYMENT_AMOUNT" ||  v[:col] == "AMOUNT_RECEIPT"
        src_insert[:activity] = activity[:activity_type] == latest_one[:activity_type]
      end
    end
    ((src_insert[:date] == true) && (src_insert[:activity] == true)) ? false : true
  end

  def self.get_card_activity_data_column
    {
        used_date: { col: "USED_DATE" },
        # カードはどちらも支出しかないのでどちらも同じ値(individual_card_outcome)で実装
        payment_amount: { col: "PAYMENT_AMOUNT",
                          income: nil,
                          income_message: nil,
                          outcome: 'individual_card_outcome',
                          outcome_message: 'クレジットカードの支出があります'
        },
    }
  end

  def self.get_bank_activity_data_column
    {
        trade_date: { col: "TRADE_DTM" },
        amount_receipt: { col: "AMOUNT_RECEIPT",
                          income: 'individual_bank_income',
                          income_message: '銀行口座に収入があります',
                          outcome: 'individual_bank_outcome',
                          outcome_message: '銀行口座の支出があります'
        },
    }
  end

  def self.get_emoney_activity_data_column
    {
        used_date: { col: "USED_DATE" },
        amount_receipt: { col: "AMOUNT_RECEIPT",
                          income: 'individual_emoney_income',
                          income_message: '電子マネーに収入があります。',
                          outcome: 'individual_emoney_outcome',
                          outcome_message: '電子マネーの支出があります。'
        },
    }
  end

  def self.create_activity_data(user_id, group_id, used_date, activity_type, activity)
    begin
      Entities::Activity.create!(
          user_id: user_id,
          group_id: group_id,
          url: activity[:url],
          count:  activity[:count],
          activity_type:  activity_type,
          message: activity[:message],
          date: used_date,
      )

    rescue => exception
      Rails.logger.info("failed to create activity ===============")
      p exception
      p exception.backtrace
    end
  end

  private
  def self.set_activity(defined_activity)
    activity = {}
    activity[:message] = defined_activity[:message]
    activity[:url] = defined_activity[:url]
    activity[:count] = 0
    activity
  end

  def self.convert_goal_message(goal, defined_activity, activity)
    activity[:message] = sprintf(defined_activity[:message], goal.name)
    activity[:url] = sprintf(defined_activity[:url], goal.id)
    activity
  end

  def self.convert_tran_url(transaction, defined_activity, activity)
    activity[:url] = sprintf(defined_activity[:url], transaction[:id], transaction[:type], transaction[:account_id])
    activity
  end

  def self.convert_user_manually_tran_url(transaction, defined_activity, activity)
    activity[:url] = sprintf(defined_activity[:url], transaction[:id], transaction[:type])
    activity
  end

  def self.convert_trans_message(transactions, defined_activity, activity)
    activity[:message] = sprintf(defined_activity[:message], transactions.count)
    activity
  end

  def self.create_base_activity(user, account)
    activity = Entities::Activity.new
    activity[:count] = 0
    activity[:user_id] = user.id
    activity[:group_id] = account[:group_id]
    activity[:date] = DateTime.new(0)
    activity[:activity_type] =nil
    activity[:message] = nil
    activity
  end

  def self.activity_assign_parameter(activity_type, options)
    defined_activity = ACTIVITY_TYPE::NAME[activity_type]
    activity = set_activity(defined_activity)
    activity = convert_goal_message(options[:goal], defined_activity, activity) if options[:goal].present?
    activity = convert_tran_url(options[:transaction], defined_activity, activity) if options[:transaction].present?
    activity = convert_user_manually_tran_url(options[:user_manually_created_transaction], defined_activity, activity) if options[:user_manually_created_transaction].present?
    activity = convert_trans_message(options[:transactions], defined_activity, activity) if options[:transactions].present?
    activity
  end

  def self.get_goal_finished(goal, options={})
    activity = activity_assign_parameter(:goal_finished, options)
    [
        {
            user_id:  options[:goal].user.id,
            group_id: goal[:group_id],
            url: activity[:url],
            count:  activity[:count],
            activity_type:  :goal_finished,
            message: activity[:message],
            date: Time.zone.now,
        },
        {
            user_id:  options[:goal].user.partner_user.id,
            group_id:  goal[:group_id],
            url: activity[:url],
            count:  activity[:count],
            activity_type:  :goal_finished,
            message: activity[:message],
            date: Time.zone.now
        }
    ]
  end
end
