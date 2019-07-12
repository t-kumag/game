class Api::V1::CategoriesController < ApplicationController

  def index

    @categories_all = Entities::AtGroupedCategory.all
    @responses = []

    @categories_all.each do |ca|

      transaction_categories = []
      ca.at_transaction_category.each do |atc|
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
end
