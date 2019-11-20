# Wrapper Class
# TODO ReportServiceと合わせて実装する
class Entities::Finance
  attr_reader :model
  def initialize(model)
    @model = model
  end

  def table_name
    model.table_name
  end

  def relation_key
    model::RELATION_KEY
  end

  def id
    model.id
  end
end
