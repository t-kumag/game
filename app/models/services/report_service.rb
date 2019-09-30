=begin
課金仕様 p.21
Usage:
Services::ReportService.new(user, nil, '2019-06-01', '2019-09-30') 自分
Services::ReportService(partner, nil, '2019-06-01', '2019-09-30') パートナー
Services::ReportService(user, partner, nil, '2019-06-01', '2019-09-30') 自分かつパートナー

構成する要素ごとにObjectを生成する
report_element1 = Services::ReportService.new(user, nil, '2019-06-01', '2019-09-30' ) 自分
report_element2 = Services::ReportService.new(partner, nil, '2019-06-01', '2019-09-30') パートナー
=end

class Services::ReportService
  attr_reader :user, :partner, :from, :to

  # userには自分自身か相手のどちらかを指定する
  # partner
  def initialize(user, partner=nil, from, to)
    @user = user
    @partner = partner
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
  end

  #TODO: WrapperClassを用意する Entities::Finance
  def bank_ids
    return [] unless @user.try()
    if @partner

    end
  end
  # 指定した月の銀行残高 from toで範囲指定なので必要なければ削除
  # Entities::BalanceLog
  def sum_bank_balance
    Entities::BalanceLog.bank_balances(ids, from, to)
  end

  # 指定した月の電子マネー残高 from toで範囲指定なので必要なければ削除
  # Entities::BalanceLog
  def sum_emoney_balance
    Entities::BalanceLog.emoney_balances(ids, from, to)
  end

  # 指定した月の銀行残高一覧 資産推移グラフ ３ヶ月などまとまった単位で必要
  # Entities::BalanceLog
  def bank_balances
    Entities::BalanceLog.bank_balances(ids, from, to)
  end

  # 指定した月の電子マネー残高一覧 資産推移グラフ ３ヶ月などまとまった単位で必要
  # Entities::BalanceLog
  def emoney_balances
    Entities::BalanceLog.emoney_balances(ids, from, to)
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