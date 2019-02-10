class Api::V1::User::PlController < ApplicationController
  before_action :authenticate

  def summaries
    @response = {
      income_amount: 1000,
      spending_amount: -1000
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def categories
    @response = {
      spending_categories: [
        {
        category_id: 1,
        name: '食費',
        amount: 100000
      }],
      income_categories: [{
        category_id: 5,
        name: '収入',
        amount: 200000
      }]
    }
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
