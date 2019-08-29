class ApplicationMailer < ActionMailer::Base
  default from: Settings.mail_setting_from,
                content_type: Settings.mail_content_type,
                parts_order: ["text/html", "text/plain"],
                charset: Settings.mail_charset
end
