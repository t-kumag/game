class Api::V2::PurchasesController < ApplicationController
  before_action :authenticate

  # AppStoreの購入確認処理
  def app_store_receipt_verification
    begin
      Services::AppDeveloperService.new(@current_user).app_store_receipt_verification(params)
    rescue StandardError => e
      return render(json: { errors: [ERROR_TYPE::NUMBER[e.message]] }, status: 422)
    rescue => e
      return render_500 e
    end
    render(json: {}, status: 204)
  end

  # GooglePlayの購入確認処理
  def google_play_receipt_verification
    begin
      Services::AppDeveloperService.new(@current_user).google_play_receipt_verification(params)
    rescue StandardError => e
      return render(json: { errors: [ERROR_TYPE::NUMBER[e.message]] }, status: 422)
    rescue => e
      return render_500 e
    end
    render(json: {}, status: 204)
  end
end
