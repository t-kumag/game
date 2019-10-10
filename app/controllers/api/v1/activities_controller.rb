class Api::V1::ActivitiesController < ApplicationController
  before_action :authenticate, except: :login

  def index


    last_sync_date = Services::AtSyncTransactionLatestDateLogService.fetch_latest_sync_log_date(@current_user)
    now = Time.now

    last_activity_sync_date = fetech_last_activity_sync_exist?
    transaction = fetch_transaction(last_sync_date, now)
    create_activity(transaction,last_activity_sync_date)


    @activities = Services::ActivityService.fetch_activities(@current_user, params[:page])
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  private

  def create_activity_options(transactions)
    options = {}
    options[:goal] = nil
    options[:transaction] = nil
    options[:transactions] = transactions
    options
  end

  def fetech_last_activity_sync_exist?
    last_activity_sync_date = {}
    person_outcome_income = Services::ActivityService.fetch_activity_type(@current_user, :person_outcome_income)
    familly_outcome_income = Services::ActivityService.fetch_activity_type(@current_user, :family_outcome_income)

    last_activity_sync_date[:person_outcome_income] = check_today?(person_outcome_income) if person_outcome_income.present?
    last_activity_sync_date[:familly_outcome_income] = check_today?(familly_outcome_income) if familly_outcome_income.present?
    last_activity_sync_date
  end

  def fetch_transaction(last_sync_date, now)
    transaction = {}
    return unless last_sync_date.present?
    transaction[:no_shared] = Entities::UserDistributedTransaction.where(user_id: @current_user.id, created_at: last_sync_date..now, share: false)
    transaction[:shared] = Entities::UserDistributedTransaction.where(user_id: @current_user.id, created_at: last_sync_date..now, share: true)
    transaction
  end

  def create_activity(transaction, last_activity_sync_date)
    if transaction[:no_shared].present? && last_activity_sync_date[:person_outcome_income].present?
      options = create_activity_options(transaction[:no_shared])
      Services::ActivityService.create_activity(@current_user.id, @current_user.group_id, Time.zone.now, :person_outcome_income, options)
    end

    if transaction[:shared].present? && last_activity_sync_date[:familly_outcome_income].present?
      options = create_activity_options(transaction[:shared])
      Services::ActivityService.create_activity(@current_user.to_user_id, @current_user.group_id, Time.zone.now, :familly_outcome_income, options)
    end
  end

  def check_today?(last_tran_date)
    now = Time.new(Time.new.year, Time.new.month, Time.new.day)
    last_tran_date = Time.new(last_tran_date.created_at.year, last_tran_date.created_at.month, last_tran_date.created_at.day)

    now != last_tran_date
  end
end
