class Api::V2::PremiumPlansController < ApplicationController
  # 選択可能なプランを返す
  def app_store
    @responses = Entities::AppStorePremiumPlan.all
    render 'app_store', formats: 'json', handlers: 'jbuilder'
    # TODO 自分が購入した場合
    # TODO 相手が購入した場合
    #
  end

  # 選択可能なプランを返す
  def google_play
    @responses = Entities::GooglePlayPremiumPlan.all
    render 'google_play', formats: 'json', handlers: 'jbuilder'
    # TODO 自分が購入した場合
    # TODO 相手が購入した場合
    #
  end
end