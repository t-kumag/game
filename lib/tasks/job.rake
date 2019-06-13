namespace :job do
  desc "ATのデータを取得して保存する"
   task sync_accounttracker: :environment do
    SyncAccounttrackerJob.perform_now
  end
end
