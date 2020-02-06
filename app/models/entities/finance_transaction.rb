# Wrapper Class
class Entities::FinanceTransaction
  attr_reader :base, :model, :relation_key, :date_column
  def initialize(obj)
    @base = obj
    @model = @base.class
    @relation_key = @model::RELATION_KEY
    @date_column = @model::DATE_COLUMN
  end

  def id
    @base.id
  end
end
