namespace :app_store do
  desc "課金の自動更新を登録する"
  task update_subscription: :environment do
    users = Entities::User.where(rank: 1).
        joins(:user_purchase).
        includes(:user_purchase).
        where(platform: 'A')

    users.each do |u|

    end

    # TODO 課金ユーザーから無料ユーザーに戻す
    # user.update_rank_free
  end
end