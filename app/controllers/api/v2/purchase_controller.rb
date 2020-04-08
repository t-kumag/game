class Api::V2::PurchaseController < ApplicationController
  before_action :authenticate

  # AppStoreの購入確認処理
  def app_store_receipt_verification
    begin
      Services::AppDeveloperService.new(@current_user).app_store_receipt_verification(params)
    rescue StandardError => e
      p e.message
      return render(json: {}, status: 422)
    rescue => e
      return render(json: {}, status: 500)
    end
    render(json: {}, status: 204)
  end

  # GooglePlayの購入確認処理
  def google_play_receipt_verification
    begin
      Services::AppDeveloperService.new(@current_user).google_play_receipt_verification(params)
    rescue StandardError => e
      p e.message
      p "asdfasf"
      return render(json: {}, status: 422)
    rescue => e
      p "asdfasf"
      return render(json: {}, status: 500)
    end
    render(json: {}, status: 204)
  end

  # 選択可能なプランを返す
  def plans
  end
end


