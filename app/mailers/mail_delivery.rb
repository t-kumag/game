
class MailDelivery < ApplicationMailer
  def user_registration(user)
    @token = user.token
    @token_expires_at = Time.parse(user.token_expires_at.to_s).strftime("%Y-%m-%d %H:%M")
    begin
      mail( :to => user.email,
            :subject => '【OsidOri】登録を完了してはじめよう')
    rescue => e
      return render_500 e
    end
  end

  def user_change_password_request(user)
    @token = user.token
    begin
      mail( :to => user.email,
            :subject => '【OsidOri】パスワード再設定のご連絡')
    rescue => e
      return render_500 e
    end
  end
  
  def account_linkage_error(user, account)
    @account = account
    begin
      mail( :to => user.email,
            :subject => '【OsidOri】口座連携エラーが発生しました')
    rescue => e
      return render_500 e
    end
  end

  def skip_scraping(user, account)
    @account = account
    begin
      mail( :to => user.email,
            :subject => '【OsidOri】口座連携エラーのためスクレイピングスキップしました。' )
    rescue => e
      return render_500 e
    end
  end

  def user_pairing(user)
    @token = user.token
    begin
      mail( :to => user.email,
            :subject => '【OsidOri】ペアリング完了です！' )
    rescue => e
      return render_500 e
    end
  end

end