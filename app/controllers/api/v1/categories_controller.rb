class Api::V1::CategoriesController < ApplicationController

  def index

    @categories_all = Entities::AtGroupedCategory.all
    @responses = []

    @categories_all.each do |ca|
      @responses << {
          at_grouped_category_id: ca.id,
          at_grouped_category_name: ca.category_name,
          at_transaction_categories: ca.at_transaction_category
      }
    end

    render 'index', formats: 'json', handlers: 'jbuilder'

  end
end
