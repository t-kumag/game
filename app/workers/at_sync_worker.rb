class AtSyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: :event

  def perform(user_id, target)
    puts 'AtSyncWorker=========='

    user = Entities::User.find(user_id)

    at_user_service = Services::AtUserService.new(user, target)
    at_user_service.exec_scraping
    at_user_service.sync

    puts 'user_distributed_transactions sync=========='
    Services::UserDistributedTransactionService.new(@current_user, params[:target]).sync
  end
end