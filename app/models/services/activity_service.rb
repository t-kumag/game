class Services::ActivityService

  def set_activity_list(rec_key, tran, account)

    activity = Entities::Activity.new
    activity[:count] = 0
    activity[:user_id] = account[:at_user_id]
    activity[:group_id] = account[:group_id]
    activity_data_column = get_activity_data_column(rec_key)

    activity_data_column.each do |k, v|
      if v[:col] == "USED_DATE" || v[:col] == "TRADE_DTM"
        activity[:date] = tran[k]
      elsif v[:col] == "PAYMENT_AMOUNT" ||  v[:col] == "AMOUNT_RECEIPT"
        activity[:activity_type] = (tran[k].to_i == 0) ? v[:income] : v[:outcome]
      end
    end

    activity
  end

  def check_activity_duplication(rec_key, activities, activity)
    old_act_latest_one = activities.present? && (activities.length - 1 >= 0) ? (activities.length - 1) : -1
    old_act_latest_two = activities.present? && (activities.length - 2 >= 0) ? (activities.length - 2) : -1
    activity_data_column = get_activity_data_column(rec_key)

    old_one = duplicate_old_act(old_act_latest_one, activity, activities, activity_data_column)
    old_two = duplicate_old_act(old_act_latest_two, activity, activities, activity_data_column)

    (old_one && old_two) ? true : false

  end

  def save_activities(activities)
    Entities::Activity.import activities, :on_duplicate_key_update => [:user_id, :date, :activity_type], :validate => false
  end

  private

  def duplicate_old_act(old_act, activity, activities, activity_data_column)

    return true if old_act < 0

    src_insert = {date: false, activity: false}

    activity_data_column.each do |k, v|
      if v[:col] == "USED_DATE" || v[:col] == "TRADE_DTM"
        src_insert[:date] = activity[:date] == activities[old_act][:date]
      elsif v[:col] == "PAYMENT_AMOUNT" ||  v[:col] == "AMOUNT_RECEIPT"
        src_insert[:activity] = activity[:activity_type] == activities[old_act][:activity_type]
      end
    end
    ((src_insert[:date] == true) && (src_insert[:activity] == true)) ? false : true
  end

  def get_activity_data_column(rec_key)
    case rec_key
    when "CARD_REC"
      get_card_activity_data_column
    when "BANK_REC"
      get_bank_activity_data_column
    when "ETC_REC"
      get_emoney_activity_data_column
    end
  end

  def get_card_activity_data_column
    {
        used_date: {col: "USED_DATE" },
        # カードはどちらも支出しかないのでどちらも同じ値(individual_card_outcome)で実装
        payment_amount: {col: "PAYMENT_AMOUNT", income: 'individual_card_outcome', outcome: 'individual_card_outcome'},
    }
  end

  def get_bank_activity_data_column
    {
        trade_date: {col: "TRADE_DTM" },
        amount_receipt: {col: "AMOUNT_RECEIPT", income: 'individual_bank_income', outcome: 'individual_bank_outcome'},
    }
  end

  def get_emoney_activity_data_column
    {
        used_date: {col: "USED_DATE" },
        amount_receipt: {col: "AMOUNT_RECEIPT", income: 'individual_emoney_income', outcome: 'individual_emoney_outcome'},
    }
  end
end
