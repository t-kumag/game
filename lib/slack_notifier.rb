module SlackNotifier
  def self.ping(message)
    begin
      sn = Slack::Notifier.new(ENV.fetch "RAILS_SLACK_NOTIFIER_WEBHOOK_URL")
      return sn.ping("#{message}") if message.class == Array || message.class == Hash
      return sn.ping("nil")  if message.nil?
      sn.ping(message)
    rescue => e
      Rails.logger.error(e)
    end
  end
end