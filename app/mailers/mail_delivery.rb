
class MailDelivery < ApplicationMailer
  def user_registration(user)
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】メールアドレス認証を完了してはじめましょう' )
  end

  def user_change_password_request(user)
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】パスワードの再設定をしてください' )
  end
  
  def account_linkage_error(user, account)
    @account = account
    mail( :to => user.email,
          :subject => '【OsidOri】口座連携エラーが発生しました' )
  end

  def skip_scraping(user, account)
    @account = account
    mail( :to => user.email,
          :subject => '【OsidOri】口座連携エラーのためスクレイピングスキップしました。' )
  end

end