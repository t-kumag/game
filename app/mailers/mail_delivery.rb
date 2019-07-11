
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
  
  def account_linkage_error(user, account)
    @error_date = account.error_date.strftime("%Y年%m月%d日 %H時%M分")
    @error_count = account.error_count
    @fnc_nm = account.fnc_nm
    @error_detail = account.last_rslt_msg

    mail( :to => user.email,
          :subject => '【OsidOri】口座連携エラーが発生しました' )
  end

  def skip_scraping(user, account)
    @error_date = account.error_date.strftime("%Y年%m月%d日 %H時%M分")
    @error_count = account.error_count
    @fnc_nm = account.fnc_nm

    mail( :to => user.email,
          :subject => '【OsidOri】口座連携エラーのためスクレイピングスキップしました。' )
  end

end