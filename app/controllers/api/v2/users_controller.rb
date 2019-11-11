class Api::V2::UsersController < ApplicationController
  before_action :authenticate, only: [:at_sync]


  def at_sync
    begin
      # ATユーザーが作成されていなければスキップする
      return render json: {}, status: 200 unless @current_user.try(:at_user)

      if params[:only_accounts] == "true"
        Services::AtUserService::Sync.new(@current_user, params[:fnc_type]).sync_accounts
        return render json: {}, status: 200
      end

      at_user_service = Services::AtUserService.new(@current_user, params[:fnc_type])
      # TODO ATのAPI一本化の対応
      # 口座登録が正常に行われているものはスクレイピング必要ないためコメント
      # リアルタイムで明細を取得したい場合に必要となるため、のちの課金対応で修正する
      # http://redmine.369webcash.com/issues/2916
      # at_user_service.exec_scraping

      at_user_service.sync_at_user_finance(request)
      at_user_service.sync_user_distributed_transaction
    rescue => e
      SlackNotifier.ping("ERROR Api::V1::UsersController#at_sync")
      SlackNotifier.ping(e)
      logger.error(e.backtrace)
    end

    render json: {}, status: 200
  end


end
