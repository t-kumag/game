# Wrapper Class
# TODO ReportServiceと合わせて実装する
class Entities::FinanceTransaction
  attr_reader :base, :table_name, :relation_key, :date_column
  def initialize(model)
    @base = model
    @table_name = @base.table_name
    @relation_key = @base::RELATION_KEY

    @date_column = @base::DATE_COLUMN
  end

end
