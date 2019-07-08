
class MailDelivery < ApplicationMailer
  def user_registration(user)
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】メールアドレスの認証をしてください' )
  end

  def user_change_password_request(user)
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】パスワードの再設定をしてください' )
  end
end