class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate

  def index

    @responses = []
    grouped_categories.each do |ca|

      transaction_categories = []
      ca.at_transaction_categories.each do |atc|
        transaction_categories << {
            at_transaction_category_id: atc.id,
            at_transaction_category_category_name1: atc.category_name2
        }
      end

      @responses << {
          at_grouped_category_id: ca.id,
          at_grouped_category_name: ca.category_name,
          at_transaction_categories: transaction_categories
      }
    end

    render 'index', formats: 'json', handlers: 'jbuilder'

  end

  private

  def grouped_categories
    if params[:type] === 'income'
      c = Entities::AtGroupedCategory.where(category_type: 'income').all.order(:order_key)
    elsif params[:type] === 'expense'
      c = Entities::AtGroupedCategory.where(category_type: 'expense').all.order(:order_key)
    else
      c = Entities::AtGroupedCategory.all.order(:order_key)
    end
    c
  end

end
