#TODO 1日1回のバッチ処理かsidekiqなどの並列処理で使用する
class Services::UserDistributedTransactionService
  def initialize(user, target = 'all')
    @user = user
    @target = target.blank? ? 'all' : target
  end

  # TODO 同じような処理を切り出すか、後の仕様で分けておいたほうが複雑にならないか検討してリファクタする
  # TODO リファクタリング
  # 負荷対応ため個別に分岐
  # 証券、保険などが増えると分岐が長くなるので渡されたmodelに対して処理を行うような作りに変える
  def sync

    begin
      case @target
      when 'bank'
        puts "sync to user_distributed_transactions bank========== "
        sync_at_user_bank_transactions
      when 'card'
        puts "sync to user_distributed_transactions card========== "
        sync_at_user_card_transactions
      when 'emoney'
        puts "sync to user_distributed_transactions emoney========== "
        sync_at_user_emoney_transactions
      else
        puts "sync to user_distributed_transactions all========== "
        sync_at_user_bank_transactions
        sync_at_user_card_transactions
        sync_at_user_emoney_transactions
      end
    end

  end

  private

  def sync_at_user_bank_transactions
    accounts = @user.at_user.at_user_bank_accounts
    accounts.each do |account|
      transactions = Entities::AtUserBankTransaction.where(at_user_bank_account_id: account.id)
      save_list = transactions.map do |transaction|
        Entities::UserDistributedTransaction.new(
          user_id: @user.id,
          share: account.share,
          used_date: transaction.trade_date,
          used_location: transaction.description1,
          amount: transaction.amount,
	  at_transaction_category_id: transaction.at_transaction_category_id,
          at_user_bank_transaction_id: transaction.id
        )
      end
      Entities::UserDistributedTransaction.import save_list,
                                                  :on_duplicate_key_update => [:user_id, :used_date, :at_user_bank_transaction_id, :amount],
                                                  :validate => false
    end
  end

  def sync_at_user_card_transactions
    accounts = @user.at_user.at_user_card_accounts
    accounts.each do |account|
      transactions = Entities::AtUserCardTransaction.where(at_user_card_account_id: account.id)
      save_list = transactions.map do |transaction|
        Entities::UserDistributedTransaction.new(
            user_id: @user.id,
            share: account.share,
            used_date: transaction.used_date,
            used_location: transaction.branch_desc,
            amount: transaction.amount,
	    at_transaction_category_id: transaction.at_transaction_category_id,
            at_user_card_transaction_id: transaction.id
        )
      end
      Entities::UserDistributedTransaction.import save_list,
                                                  :on_duplicate_key_update => [:user_id, :used_date, :at_user_card_transaction_id, :amount],
                                                  :validate => false
    end
  end

  def sync_at_user_emoney_transactions
    accounts = @user.at_user.at_user_emoney_service_accounts
    accounts.each do |account|
      transactions = Entities::AtUserEmoneyTransaction.where(at_user_emoney_service_account_id: account.id)
      save_list = transactions.map do |transaction|
        Entities::UserDistributedTransaction.new(
            user_id: @user.id,
            share: account.share,
            used_date: transaction.used_date,
            used_location: transaction.description,
            amount: transaction.amount,
	    at_transaction_category_id: transaction.at_transaction_category_id,
            at_user_emoney_transaction_id: transaction.id
        )
      end
      Entities::UserDistributedTransaction.import save_list,
                                                  :on_duplicate_key_update => [:user_id, :used_date, :at_user_emoney_transaction_id, :amount],
                                                  :validate => false
    end
  end

  # TODO 手動明細 口座という概念がないのでどの目標に紐づくかの情報が必要
  def sync_user_manually_created_transactions

  end
end
