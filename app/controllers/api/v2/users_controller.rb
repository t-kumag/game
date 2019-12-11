class Api::V2::UsersController < ApplicationController
  before_action :authenticate, only: [:status]

  def status
    response = {
      user_status: {
        user_id: @current_user.id,
        mail_registered: @current_user.email.present?,
        mail_authenticated: @current_user.email_authenticated,
        finance_registered: finance_registered?,
        goal_created: goal_created?,
        transaction_shared: transaction_shared?,
        finance_shared: finance_shared?,
        paired: @current_user.partner_user.present?,
        group_goal_created: goal_created?(true),
        group_transaction_shared: transaction_shared?(true),
        group_finance_shared: finance_shared?(true)
      }
    }
    render json: response, status: 200
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
    user_ids = [@current_user.id]
    return Entities::UserDistributedTransaction.where(user_id: user_ids, share: true).present? unless with_group
    
    user_ids.push(@current_user.partner_user.id) if @current_user.partner_user.present?
    Entities::UserDistributedTransaction.where(user_id: user_ids, share: true).present?
  end

  def finance_shared?(with_group=false)
    shared_bank_account_ids = @current_user.try(:at_user).try(:at_user_bank_accounts).try(:where, share:true).try(:pluck ,:id)
    shared_card_account_ids = @current_user.try(:at_user).try(:at_user_card_accounts).try(:where, share:true).try(:pluck ,:id)
    shared_emoney_account_ids = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:where, share:true).try(:pluck ,:id)
    return shared_bank_account_ids.present? || shared_card_account_ids.present? || shared_emoney_account_ids.present? unless with_group

    if @current_user.partner_user.present?
      shared_bank_account_ids = @current_user.partner_user.try(:at_user).try(:at_user_bank_accounts).try(:where, share:true).try(:pluck ,:id)
      shared_card_account_ids = @current_user.partner_user.try(:at_user).try(:at_user_card_accounts).try(:where, share:true).try(:pluck ,:id)
      shared_emoney_account_ids = @current_user.partner_user.try(:at_user).try(:at_user_emoney_service_accounts).try(:where, share:true).try(:pluck ,:id)
      shared_bank_account_ids.flatten!
      shared_card_account_ids.flatten!
      shared_emoney_account_ids.flatten!
    end
        
    shared_bank_account_ids.present? || shared_card_account_ids.present? || shared_emoney_account_ids.present? 
  end
end
