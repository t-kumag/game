class Api::V2::PaymentMethodsController < ApplicationController
  before_action :authenticate

  def index
    @responses = Services::PaymentMethodService.new(@current_user).payment_methods
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
