
class MailDelivery < ApplicationMailer
  def user_registration(user)
    #TODO メール本文が決まったら差し替える
    mail( :to => user.email,
          :subject => 'Osidori本登録のお知らせ' )
  end
end