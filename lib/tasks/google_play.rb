namespace :google_play do
  desc "課金の自動更新を登録する"
  task update_subscription: :environment do

    # TODO 課金ユーザーから無料ユーザーに戻す
    # user.update_rank_free
  end
end