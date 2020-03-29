class Services::CategoryService

  def initialize(category_version)
    @category_version = category_version
  end

  def category_map
    max_version = Entities::AtGroupedCategory.all.pluck(:version).max
    category_map = nil
    if @category_version.to_s == max_version.to_s
      categories = get_transaction_categories(@category_version)
      category_map = categories.map{ |category| [category['id'], category]}.to_h
    else
      category_map = {}
      now_categories = get_transaction_categories(@category_version)
      max_categories = get_transaction_categories(max_version)
      undefined_category = get_undefined_transaction_category(max_version)

      max_categories.each do |max_category|
        now_categories.each do |now_category|
          if nil != max_category['before_version_id'] && max_category['before_version_id'] == now_category['id']
            category_map[max_category['id']] = now_category
            break
          end
          category_map[max_category['id']] = undefined_category[0].to_h
        end
      end
    end
    category_map
  end

  def convert_at_transaction_category_id(at_transaction_category_id)
    max_version = Entities::AtGroupedCategory.all.pluck(:version).max
    if (@category_version.to_s == max_version.to_s)
      return at_transaction_category_id
    else
      at_transaction_category = Entities::AtTransactionCategory.joins(:at_grouped_category).where(before_version_id: at_transaction_category_id, at_grouped_categories: {version: max_version})
      return at_transaction_category[0].id
    end
  end

  def category_name_map
    category = Entities::AtTransactionCategory.joins(:at_grouped_category).where(at_grouped_categories: {version: @category_version})
    category.map{ |category| [category['id'], {category_name1: category[:category_name1], category_name2: category[:category_name2]}]}.to_h
  end

  def get_undefined_transaction_category(version)
    sql = <<-EOS
    SELECT
      atc.id
      , atc.before_version_id
      , atc.category_name1
      , atc.category_name2
    FROM
      at_transaction_categories atc
    LEFT JOIN
      at_grouped_categories agc
    ON
      agc.id = atc.at_grouped_category_id
    WHERE
      agc.version=#{version}
      AND atc.at_category_id = "0000"
    EOS
    ActiveRecord::Base.connection.select_all(sql)
  end

private
  def get_transaction_categories(version)
    sql = <<-EOS
    SELECT
      atc.id
      , atc.before_version_id
      , atc.category_name1
      , atc.category_name2
    FROM
      at_transaction_categories atc
    LEFT JOIN
      at_grouped_categories agc
    ON
      agc.id = atc.at_grouped_category_id
    WHERE
      agc.version=#{version}
    EOS
    ActiveRecord::Base.connection.select_all(sql)
  end
end
