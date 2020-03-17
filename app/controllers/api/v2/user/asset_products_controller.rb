class Api::V2::User::AssetProductsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:stock_account_id].to_i
    if disallowed_at_stock_ids?([account_id])
      render_disallowed_financier_ids && return
    end
    @asset_products = Services::AtAssetProductService.new(@current_user).list(account_id)
    render(json: {}, status: 204) && return if @asset_products.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
