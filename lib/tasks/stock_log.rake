namespace :stock_log do
  desc "証券評価額の履歴登録"

  # rake stock_log:insert
  # 毎日15:00に実行する。
  # at_user_stock_accountsのbalance,deposit_balance,profit_loss_amountの値を取得し日毎に保持する。
  # 口座連携エラー時には取得しない。
  # gem paranoia（論理削除）によりat_user_stock_accounts.deleted_at is not nullのアカウントは含まれない。
  # ATデータの取得はATが1リクエスト、1ユーザーしか受け付けない仕様のため1件づつ行う。
  task insert: :environment do
    require 'parallel'
    parallel_num = 2 # スレッド数 指定数分のレコードを保持しスレッド処理する
    beginning_of_day = Time.zone.now.beginning_of_day
    end_of_day = Time.zone.now.end_of_day

    Entities::AtUserStockAccount.find_in_batches(batch_size: parallel_num) do |stock_accounts|
      Parallel.each(stock_accounts, in_processes: parallel_num) do |sa|
        begin
          stock_log = Entities::AtUserStockLog.
                      where(at_user_stock_account_id: sa.id).
                      where('created_at >= ?', beginning_of_day).
                      where('created_at <= ?', end_of_day).
                      first
          next if stock_log.present? # 証券ログが取得済みの場合はnext

          user = sa.try(:at_user).try(:user)
          next if user.blank? # ユーザーが退会済みの場合はnext

          # atのtokenをバッチモードで更新
          Services::AtUserService.new(user).batch_yn = 'Y'

          # at_user_stock_accounts同期 金融エラーチェック
          Services::AtUserService.new(user, 'stock').sync_at_user_finance
          stock_acount = Entities::AtUserStockAccount.find_by(id: sa.id)
          next if stock_acount.blank?
          next if stock_acount.last_rslt_cd != '0' # 正常:0 以外はnext

          stock_acount.balance
          stock_acount.deposit_balance
          stock_acount.profit_loss_amount

          save_stock_log = Entities::AtUserStockLog.new
          save_stock_log.at_user_stock_account_id = sa.id
          save_stock_log.balance = stock_acount.balance
          save_stock_log.deposit_balance = stock_acount.deposit_balance
          save_stock_log.profit_loss_amount = stock_acount.profit_loss_amount

          save_stock_log.save!
        rescue => e
          Rails.logger.error('ERROR rake stock_log:insert')
          SlackNotifier.ping('ERROR rake stock_log:insert')
          Rails.logger.error(e)
          SlackNotifier.ping(e)
          if user.present?
            Rails.logger.error(user)
            SlackNotifier.ping(user)
          end
          if stock_log.present?
            Rails.logger.error(stock_log)
            SlackNotifier.ping(stock_log)
          end
        end
      end
    end
  end
end
