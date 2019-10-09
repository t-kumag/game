class Services::ActivityService

  def self.get_activity_data(user_id, group_id, activity_type)
    {
        user_id: user_id,
        group_id: group_id,
        count: 0,
        activity_type: activity_type,
        date: Time.zone.now
    }
  end

  def self.save_activities(activities)
    Entities::Activity.import activities, :on_duplicate_key_update => [:user_id, :date, :activity_type], :validate => false
  end

  def self.create_activity(user_id, group_id=nil, used_date, activity_type, options = {})

    message_and_url = fetch_activity(activity_type)
    message_and_url = activity_message_replace_with_suitable_goal_message(options[:goal], message_and_url) if options[:goal].present?
    message_and_url = activity_url_replace_with_suitable_transactioi_url(options[:transaction], message_and_url) if options[:transaction].present?

    create_activity_data(user_id, group_id, used_date, activity_type, message_and_url)
  end

  def self.set_activity_list(financier_account_type_key, tran, account, user)
    activity = Entities::Activity.new
    activity[:count] = 0
    activity[:user_id] = user.id
    activity[:group_id] = account[:group_id]
    activity_data_column = get_activity_data_column(financier_account_type_key)

    activity_data_column.each do |k, v|
      if v[:col] == "USED_DATE" || v[:col] == "TRADE_DTM"
        activity[:date] = tran[k]
      elsif v[:col] == "PAYMENT_AMOUNT" ||  v[:col] == "AMOUNT_RECEIPT"
        activity[:activity_type] = (tran[k].to_i == 0) ? v[:income] : v[:outcome]
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

  def self.fetch_activities(current_user, page)
    Entities::Activity.where(user_id: current_user.id).order(created_at: "DESC").page(page)
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
        payment_amount: { col: "PAYMENT_AMOUNT", income: 'individual_card_outcome', outcome: 'individual_card_outcome' },
    }
  end

  def self.get_bank_activity_data_column
    {
        trade_date: { col: "TRADE_DTM" },
        amount_receipt: { col: "AMOUNT_RECEIPT", income: 'individual_bank_income', outcome: 'individual_bank_outcome' },
    }
  end

  def self.get_emoney_activity_data_column
    {
        used_date: { col: "USED_DATE" },
        amount_receipt: { col: "AMOUNT_RECEIPT", income: 'individual_emoney_income', outcome: 'individual_emoney_outcome' },
    }
  end

  def self.create_activity_data(user_id, group_id, used_date, activity_type, message_and_url)
    begin
      Entities::Activity.create!(
          user_id: user_id,
          group_id: group_id,
          url: message_and_url[:url],
          count:  0,
          activity_type:  activity_type,
          message: message_and_url[:message],
          date: used_date
      )
    rescue => exception
      Rails.logger.info("failed to create activity ===============")
      raise exception
    end
  end

  def self.fetch_activity(activity_type)
    ACTIVITY_TYPE::NAME[activity_type]
  end

  def self.activity_message_replace_with_suitable_goal_message(goal, message_and_url)
    message_and_url[:message] = sprintf(message_and_url[:message], goal.name)
    message_and_url
  end

  def self.activity_url_replace_with_suitable_transactioi_url(transaction, message_and_url)
    message_and_url[:url] = sprintf(message_and_url[:url], transaction.id)
    message_and_url
  end
end
