class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate

  def index
    @category_service = Services::CategoryService.new(@category_version)
    unless @category_service.is_support_version?
      render_disallowed_support_category_version && return
    end

    ids = nil
    unless @category_service.is_latest_version?
      ids = Entities::AtTransactionCategory.joins(:at_grouped_category).where(at_grouped_categories: {version: @category_service.latest_version})
      ids = ids.pluck(:before_version_id)
    end
    @responses = []
    grouped_categories.each do |ca|
      transaction_categories = []
      ca.at_transaction_categories.each do |atc|

        if ids.nil? || ids.try(:include?, atc.id)
          transaction_categories << {
              at_transaction_category_id: atc.id,
              at_transaction_category_category_name1: atc.category_name2
          }
        end
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
      c = Entities::AtGroupedCategory.where(category_type: 'income', version: @category_version).order(:order_key)
    elsif params[:type] === 'expense'
      c = Entities::AtGroupedCategory.where(category_type: 'expense', version: @category_version).order(:order_key)
    else
      c = Entities::AtGroupedCategory.where(version: @category_version).order(:order_key)
    end
    c
  end

end
