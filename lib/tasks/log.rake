
desc "Migrate実行時にSQLの出力をする"
task log: :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
