# Wrapper Class
class Entities::Finance
  attr_reader :base, :model, :relation_key
  def initialize(obj)
    @base = obj
    @model = @base.class
    @relation_key = @model::RELATION_KEY
  end

  def balance(date= nil)
    date ||= Time.zone.now.strftime("%Y-%m-%d")
    # 日付が当日の場合はリアルタイムな残高を返す
    return @base.balance if Time.zone.now.strftime("%Y-%m-%d") ==  Time.zone.parse(date).strftime("%Y-%m-%d")
    # 日付が前日より前の場合はbalance_logsから取得
    bl = Entities::BalanceLog.find_by(@relation_key => @base.id, date: date)
    bl.present? ? bl.amount : 0
  end

  def id
    @base.id
  end
end