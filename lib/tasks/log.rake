case Rails.env
when "development"
  # 開発環境のコード
  desc "Migrate実行時にSQLの出力をする"
  task log: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
end
