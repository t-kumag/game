class Services::AtAssetProductService
  def initialize(user)
    @user = user
  end

  def list(account_id)
    asset_products = Entities::AtUserAssetProduct.where(at_user_stock_account_id: account_id)
    return [] if asset_products.blank?
    type_sort(asset_products)
  end

  private

  def type_sort(asset_products)
    result = []
    Entities::AtUserAssetProduct::ASSETS_PRODUCT_NAME.each do |k, _|
      asset_products.each_with_index do |ap_v, ap_i|
        result << asset_products[ap_i] if k == ap_v.assets_product_type
      end
    end
    result
  end
end
