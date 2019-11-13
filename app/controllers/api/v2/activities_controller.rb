class Api::V2::ActivitiesController < ApplicationController
  before_action :authenticate, except: :login

  def index

    ## アクティティの件数を出す際にメモする時間
    at_sync_transaction_latest_date = Services::ActivityService.fetch_at_sync_transaction_latest_date(@current_user)

    # at-sync時にアクティビティが追加される際に記載する時間
    sync_criteria_date = Services::ActivityService.fetch_sync_criteria_date(@current_user)

    last_activity_sync_date = last_activity_sync_exist?(sync_criteria_date)
    transaction = fetch_transaction(sync_criteria_date, Time.now)
    create_activity(transaction,last_activity_sync_date, sync_criteria_date)

    @activities = Services::ActivityService.fetch_activities(@current_user, params[:page])
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  private

  def create_activity_options(transactions, last_sync_date)
    options = {}
    options[:goal] = nil
    options[:transaction] = nil
    options[:transactions] = transactions
    options[:at_sync_transaction_latest_date] = last_sync_date
    options
  end

  def last_activity_sync_exist?(sync_criteria_date)

    last_activity_sync_date = {}
    last_activity_sync_date[:person_expense_income] = true
    last_activity_sync_date[:familly_expense_income] = true
    return last_activity_sync_date unless sync_criteria_date

    person_expense_income = Services::ActivityService.fetch_activity_type(@current_user, :person_expense_income)
    familly_expense_income = Services::ActivityService.fetch_activity_type(@current_user, :familly_expense_income)

    last_activity_sync_date[:person_expense_income] = check_latest_day?(person_expense_income, sync_criteria_date) if person_expense_income.present?
    last_activity_sync_date[:familly_expense_income] = check_latest_day?(familly_expense_income, sync_criteria_date) if familly_expense_income.present?
    last_activity_sync_date
  end

  def fetch_transaction(sync_criteria_date, now)
    transaction = {}
    transaction[:no_shared] = nil
    transaction[:shared] = nil

    return transaction unless sync_criteria_date.present?
    transaction[:no_shared] = Entities::UserDistributedTransaction.where(user_id: @current_user.id, created_at: sync_criteria_date..now, share: false)
    transaction[:shared] = Entities::UserDistributedTransaction.where(user_id: @current_user.id, created_at: sync_criteria_date..now, share: true)

    transaction[:no_shared] = remove_user_manually_created_transaction(transaction[:no_shared])
    transaction[:shared] = remove_user_manually_created_transaction(transaction[:shared])
    transaction
  end

  def create_activity(transaction, last_activity_sync_date, sync_criteria_date)
    if transaction[:no_shared].present? && last_activity_sync_date[:person_expense_income]
      options = create_activity_options(transaction[:no_shared], sync_criteria_date)
      Services::ActivityService.create_activity(@current_user.id, @current_user.group_id, Time.zone.now, :person_expense_income, options)
    end

    if transaction[:shared].present? && last_activity_sync_date[:familly_expense_income]
      options = create_activity_options(transaction[:shared], sync_criteria_date)
      Services::ActivityService.create_activity(@current_user.id, @current_user.group_id, Time.zone.now, :familly_expense_income, options)
    end
  end

  def check_latest_day?(last_tran_date, sync_criteria_date)
    last_tran_date.at_sync_transaction_latest_date != sync_criteria_date
  end

  def remove_user_manually_created_transaction(transactions)
    transactions.reject do |t|
      if t.user_manually_created_transaction_id.present?
        # 手動明細は削除する
        true
      else
        # 手動明細以外は削除しない
        false
      end
    end
  end

end
