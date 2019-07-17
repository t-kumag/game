# TODO AWSの環境ごとに分ける処理が必要
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL"), namespace: 'event' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL"), namespace: 'event' }
end