=begin
課金仕様 p.21
Usage:
Services::ReportService.new(user, false, '2019-06-01', '2019-09-30') 自分
Services::ReportService(partner, false, '2019-06-01', '2019-09-30') パートナー
Services::ReportService(user, true, '2019-06-01', '2019-09-30') 自分かつパートナー

構成する要素ごとにObjectを生成する
report_element1 = Services::ReportService.new(user, false, '2019-06-01', '2019-09-30' ) 自分
report_element2 = Services::ReportService.new(partner, false, '2019-06-01', '2019-09-30') パートナー

構成する要素のパターン
当月、前月
自分、パートナー

=end

class Services::ReportService
  attr_reader :user, :partner, :users, :from, :to

  # userには自分自身か相手のどちらかを指定する
  # partner
  def initialize(user, with_partner=false, from=nil, to=nil)
    @user = user
    @partner = with_partner ? @user.partner_user : nil
    @users = partner ? [user, partner] : [user]
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
  end

  # 指定した月の銀行残高一覧 資産推移グラフ ３ヶ月などまとまった単位で必要
  # Entities::BalanceLog
  def balances(model)
    # TODO ReportServiceと合わせて実装する
    finance = Entities::Finance,new(model)
    finances = finances(users, finance)
    return [] if finances.blank?
    # TODO 実装
    Entities::BalanceLog.balances(finances.pluck(:id), from, to)
    {
      balances: [
        {
          finance.relation_key.to_sym => 5,
          amount: 3,
          date: '2019-09-30 23:59:59'
        }
      ],
      total_amount: 0
    }
  end

  # 振り分け金額合計と件数
  # Entities::UserDistributedTransaction
  def distributed_transactions_total
    # user_id 自分 group_id
    Entities::UserDistributedTransaction
    # user_id 相手 group_id
    {
      amount: 100,
      count: 3
    }
  end


  # 明細一覧（内訳）
  # Services::TransactionServiceのWrapper
  def transactions
  end

  private

  def finances(users, finance)
    [1,2]
  end
end