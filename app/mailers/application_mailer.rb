class ApplicationMailer < ActionMailer::Base
  default from: Settings.mail_setting_from
end
