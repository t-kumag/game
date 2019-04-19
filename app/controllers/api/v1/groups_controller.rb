class Api::V1::GroupsController < ApplicationController
  before_action :authenticate

  def generate_pairing_token
    

    render 'generate_pairing_token', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def pairing
    params[:pairing_token]
    render 'pairing', formats: 'json', handlers: 'jbuilder', status: 200
  end

end
