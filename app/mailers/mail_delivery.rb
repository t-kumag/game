
class MailDelivery < ApplicationMailer
  def user_registration(user)
    #TODO メール本文が決まったら差し替える
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】メールアドレスの認証をしてください' )
  end

  def user_change_password_request(user)
    #TODO メール本文が決まったら差し替える
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】メールアドレスの認証をしてください' )
  end
end