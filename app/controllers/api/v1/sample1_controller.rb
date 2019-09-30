=begin
  Only Rails.env.development
  Sample、検証用のController
=end
class Api::V1::Sample1Controller < ApplicationController
  before_action :authenticate

  def report
    render 'report', formats: 'json', handlers: 'jbuilder', status: 200
  end

end