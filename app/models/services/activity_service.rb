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

  def self.create_user_activity(user_id, group_id, used_date, activity_type, goal=nil, transaction_id=nil)

    message_and_url = nil

    if goal.present?
      message_and_url = fetch_activity_goal_message_and_url(activity_type, goal)
    elsif transaction_id.present?
      message_and_url = fetch_activity_transaction_message_and_url(activity_type, transaction_id)
    else
      message_and_url = fetch_activity_message_and_url(activity_type)
    end

    activity_find_or_create(user_id, group_id, used_date, activity_type, message_and_url)
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

  def self.activity_find_or_create(user_id, group_id, used_date, activity_type, message_and_url)
    # DBは拡張する予定なので、保存する領域を増やす。
    # activity.url, activity.message,
    Entities::Activity.find_or_create_by(user_id: user_id, date: used_date, activity_type: activity_type) do |activity|
      activity.user_id = user_id
      activity.group_id = group_id
      activity.url = message_and_url[:url]
      activity.count = 0
      activity.activity_type = activity_type
      activity.message = message_and_url[:message]
      activity.date = used_date
    end
  end

  def self.fetch_activity_message_and_url(activity_type)
    ACTIVITY_TYPE::NAME[activity_type]
  end

  def self.fetch_activity_goal_message_and_url(activity_type, goal)
    activity_message_and_url = ACTIVITY_TYPE::NAME[activity_type]
    activity_message_and_url[:message] = printf(activity_message_and_url[:message], goal.name)
    activity_message_and_url
  end

  def self.fetch_activity_transaction_message_and_url(activity_type, transaction)
    activity_message_and_url = ACTIVITY_TYPE::NAME[activity_type]
    activity_message_and_url[:url] = printf(activity_message_and_url[:url], transaction.id)
    activity_message_and_url
  end


  # 一つの関数では一つの機能を守るように遵守する。

  # 文言の取得方法について
  # config/initializers/activity.rbに定義した定数を取得
  # 定数は連想配列で定義され、引数によって文字を変換することができる
  # その定数からtypeをキーにオブジェクトを取得
  #
  # オブジェクトの形は下記を想定
  #
  # 例１) ペアリングの場合
  # {
  #     message: "ペアリング完了しました。",
  #     url: ""
  # }
  #
  #
  # 例１) 目標作成の場合
  # {
  #     message: "目標貯金「テスト目標」が作成されました。",
  #     url: "osidori://"
  # }
  #
  #
  #
end
