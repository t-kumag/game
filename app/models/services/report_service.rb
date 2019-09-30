=begin
課金仕様 p.21
Usage:
Services::ReportService.new(user) 自分
Services::ReportService(partner) パートナー
Services::ReportService(user, partner) 自分かつパートナー

構成する要素ごとにObjectを生成する
report_element1 = Services::ReportService.new(user) 自分
report_element2 = Services::ReportService.new(partner) パートナー
=end

class Services::ReportService
  attr_reader :user, :partner, :with_partner

  # userには自分自身か相手のどちらかを指定する
  # partner
  def initialize(user, partner=nil)
    @user = user
    @partner = partner
    @with_partner = with_partner
    @from #月初
    @to #月末
  end

  # 指定した月の銀行残高 from toで範囲指定なので必要なければ削除
  # Entities::BalanceLog
  def bank_balance
  end

  # 指定した月の電子マネー残高 from toで範囲指定なので必要なければ削除
  # Entities::BalanceLog
  def emoney_balance
  end

  # 指定した月の銀行残高一覧 資産推移グラフ ３ヶ月などまとまった単位で必要
  # Entities::BalanceLog
  def bank_balances
  end

  # 指定した月の電子マネー残高一覧 資産推移グラフ ３ヶ月などまとまった単位で必要
  # Entities::BalanceLog
  def emoney_balances
  end

  # 振り分け金額合計
  # Services::TransactionService
  def distribute_transactions_total_amount
  end

  # 振り分け件数合計
  # Services::TransactionService
  def distribute_transactions_total_count
  end

  # 明細一覧（内訳）
  # Services::TransactionServiceのWrapper
  def transactions
  end

  # 金融
  # 目標
  # BS
  # PL
  # 振り分け
  # 明細一覧（内訳）
end