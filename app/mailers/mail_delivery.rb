
class MailDelivery < ApplicationMailer
  def user_registration(user)
    @token = user.token
    @token_expires_at = Time.parse(user.token_expires_at.to_s).strftime("%Y-%m-%d %H:%M")
    mail( :to => user.email,
          :subject => '【OsidOri】登録を完了してはじめよう' )
  end

  def user_change_password_request(user)
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】パスワード再設定のご連絡' )
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

  def user_pairing(user)
    @token = user.token
    mail( :to => user.email,
          :subject => '【OsidOri】ペアリング完了です！' )
  end

end