class Api::V2::UsersController < ApplicationController
  before_action :authenticate_token, only: [:status]

  def status
    return render json: { errors: [ERROR_TYPE::NUMBER['001003']] }, status: 422 if @current_user.nil?
    if @current_user.email_authenticated
      @response = {
        finance_registered: finance_registered?,
        goal_created: goal_created?,
        transaction_shared: transaction_shared?,
        finance_shared: finance_shared?,
        group_goal_created: goal_created?(true),
        group_transaction_shared: transaction_shared?(true),
        group_finance_shared: finance_shared?(true)
      }
      render 'status', formats: 'json', handlers: 'jbuilder'
    else
      render 'not_email_authenticated', formats: 'json', handlers: 'jbuilder'
    end
  end

  
  def finance_registered?
    bank_account_ids = @current_user.try(:at_user).try(:at_user_bank_accounts).try(:pluck ,:id)
    card_account_ids = @current_user.try(:at_user).try(:at_user_card_accounts).try(:pluck ,:id)
    emoney_account_ids = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:pluck ,:id)
    bank_account_ids.present? || card_account_ids.present? || emoney_account_ids.present? 
  end
  
  def goal_created?(with_group=false)
    user_ids = [@current_user.id]
    return Entities::Goal.find_by(user_id: user_ids).present? unless with_group

    user_ids.push(@current_user.partner_user.id) if @current_user.partner_user.present?
    Entities::Goal.find_by(user_id: user_ids).present?
  end

  def transaction_shared?(with_group=false)
    account_ids = {}
    result = false

    # 金融口座ID取得 手動明細の共有チェック
    if with_group === false
      account_ids = Services::FinanceService.new(@current_user).all_account_ids
      result = Entities::UserDistributedTransaction.
        joins(:user_manually_created_transaction).
        where(user_id: @current_user.id, share: true).
        present?
    elsif with_group === true && @current_user.partner_user.present?
      account_ids = Services::FinanceService.new(@current_user).all_account_ids(true)
      result = Entities::UserDistributedTransaction.
        joins(:user_manually_created_transaction).
        where(user_id: [@current_user.id, @current_user.partner_user.id], share: true).
        present?
    end
    return true if result === true
    account_ids.each do |type, ids|
      next if ids.blank?
      case type
      when :bank
        result = Entities::UserDistributedTransaction.
          joins(:at_user_bank_transaction).
          where("at_user_bank_transactions.at_user_bank_account_id" => ids).
            where(share: true).
            present?
      when :card
        result = Entities::UserDistributedTransaction.
            joins(:at_user_card_transaction).
            where("at_user_card_transactions.at_user_card_account_id" => ids).
            where(share: true).
            present?
      when :emoney
        result = Entities::UserDistributedTransaction.
            joins(:at_user_emoney_transaction).
            where("at_user_emoney_transactions.at_user_emoney_service_account_id" => ids).
            where(share: true).
            present?
      when :wallet
        result = Entities::UserDistributedTransaction.
            joins(:user_manually_created_transaction).
            where(
              "user_manually_created_transactions.payment_method_type" => "wallet",
              "user_manually_created_transactions.payment_method_id" => ids).
            where(share: true).
            present?
      end
      return true if result === true
    end
    false
  end

  def finance_shared?(with_group=false)
    shared_bank_account_ids = @current_user.try(:at_user).try(:at_user_bank_accounts).try(:where, share:true).try(:pluck ,:id)
    shared_card_account_ids = @current_user.try(:at_user).try(:at_user_card_accounts).try(:where, share:true).try(:pluck ,:id)
    shared_emoney_account_ids = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:where, share:true).try(:pluck ,:id)
    return shared_bank_account_ids.present? || shared_card_account_ids.present? || shared_emoney_account_ids.present? unless with_group

    if @current_user.partner_user.present?
      if shared_bank_account_ids.present? 
        shared_bank_account_ids << @current_user.partner_user.try(:at_user).try(:at_user_bank_accounts).try(:where, share:true).try(:pluck ,:id)
      else
        shared_bank_account_ids = @current_user.partner_user.try(:at_user).try(:at_user_bank_accounts).try(:where, share:true).try(:pluck ,:id)
      end

      if shared_card_account_ids.present? 
        shared_card_account_ids << @current_user.partner_user.try(:at_user).try(:at_user_card_accounts).try(:where, share:true).try(:pluck ,:id)
      else
        shared_card_account_ids = @current_user.partner_user.try(:at_user).try(:at_user_card_accounts).try(:where, share:true).try(:pluck ,:id)
      end

      if shared_emoney_account_ids.present? 
        shared_emoney_account_ids << @current_user.partner_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:where, share:true).try(:pluck ,:id)
      else
        shared_emoney_account_ids = @current_user.partner_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:where, share:true).try(:pluck ,:id)
      end

      shared_bank_account_ids.try(:flatten!)
      shared_card_account_ids.try(:flatten!)
      shared_emoney_account_ids.try(:flatten!)
    end
        
    shared_bank_account_ids.present? || shared_card_account_ids.present? || shared_emoney_account_ids.present? 
  end
end
