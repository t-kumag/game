class Api::V2::Group::AssetProductsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:stock_account_id].to_i
    if disallowed_at_stock_ids?([account_id])
      render_disallowed_financier_ids && return
    end
    @asset_products = Entities::AtUserAssetProduct.where(at_user_stock_account_id: account_id)
    render json: {}, status: 204 and return if @asset_products.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
