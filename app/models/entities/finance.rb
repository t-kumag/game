# Wrapper Class
# TODO ReportServiceと合わせて実装する
class Entities::Finance
  attr_reader :base, :model, :relation_key, :table_name
  def initialize(model, id)
    @base = model
    @model = model.find(id)
    @relation_key = @base::RELATION_KEY
    @table_name = @base.table_name
  end

  def balance(date= nil)
    date ||= Time.zone.now.strftime("%Y-%m-%d")
    # 日付が当日の場合はリアルタイムな残高を返す
    return @model.balance if Time.zone.now.strftime("%Y-%m-%d") ==  Time.zone.parse(date).strftime("%Y-%m-%d")
    # 日付が前日より前の場合はbalance_logsから取得
    bl = Entities::BalanceLog.find_by(@relation_key => @model.id, date: date)
    bl.present? ? bl.amount : 0
  end

  def id
    @model.id
  end
end