class Api::V2::PurchaseController < ApplicationController
  before_action :authenticate

  # AppStoreの購入確認処理
  def app_store_receipt_verification
    begin
      res = Services::AppDeveloperService.new(@current_user).app_store_receipt_verification(params)
    rescue StandardError => e
      #TODO エラーコードごとのレンダリングを行う
      if e.message
        render(json: {})
      end
      render(json: {})
    end

  end

  # GooglePlayの購入確認処理
  def google_play_receipt_verification
    begin
      res = Services::AppDeveloperService.new(@current_user).google_play_receipt_verification(params)
    rescue StandardError => e
      #TODO エラーコードごとのレンダリングを行う
      if e.message
        render(json: {})
      end
      render(json: {})
    end
  end

  # 選択可能なプランを返す
  def plans
  end
end


