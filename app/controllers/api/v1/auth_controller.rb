class AuthController < ApplicationController
  def login
    @user = Entities::User.find(:first, :conditions => { :email => prams[:email], :crypted_password => params[:crypted_password] })
  end
end
