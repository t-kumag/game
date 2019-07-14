# TODO AWSの環境ごとに分ける処理が必要
Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:6379', namespace: 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379', namespace: 'sidekiq' }
end