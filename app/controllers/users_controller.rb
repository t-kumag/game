class UsersController < ApplicationController
  def at_user_create
    @result_json = {
        aaa: ''
    }
    render 'at_user_create', formats: 'json', handlers: 'jbuilder'
  end
end
