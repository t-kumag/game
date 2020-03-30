# カテゴリを管理する。
# 最新バージョンと、最新バージョンから１世代前の互換性を保たせる。
# 2世代前との互換性は保証しない。
class Services::CategoryService

  def initialize(category_version)
    @category_version = category_version
    @latest_version = Entities::AtGroupedCategory.all.pluck(:version).max.to_s
    @is_latest_version = @category_version.to_s == @latest_version.to_s
  end

  def is_latest_version?
    @is_latest_version
  end

  # 最新のカテゴリID（各テーブルに入っているat_transaction_category_id）と
  # アプリのカテゴリバージョンのカテゴリID、カテゴリ名１、カテゴリ名２の連想配列を作成する
  # 最新の例) {272=>{"id"=>272, "before_version_id"=>19, "category_name1"=>"食費", "category_name2"=>"食費"}}
  # 旧の例) {272=>{"id"=>19, "before_version_id"=>nil, "category_name1"=>"食費", "category_name2"=>"パン、サンドイッチ"}}
  def category_map
    category_map = nil
    if self.is_latest_version?
      categories = get_transaction_categories(@category_version)
      category_map = categories.map{ |category| [category['id'], category]}.to_h
    else
      category_map = {}
      now_categories = get_transaction_categories(@category_version)
      max_categories = get_transaction_categories(@latest_version)
      undefined_category = get_undefined_transaction_category(@latest_version)

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

  # 最新バージョンのカテゴリIDに置き換える
  # アプリのカテゴリバージョンと最新バージョンが一致する場合、そのまま返す。
  # 一致しない場合、before_version_idにリクエストされたカテゴリIDが入っているIDを返す。
  #　　例）19(食費=>パン、サンドイッチ) の場合、272(食費=>食費)を返す
  def convert_at_transaction_category_id(at_transaction_category_id)
    if self.is_latest_version?
      return at_transaction_category_id
    else
      at_transaction_category = Entities::AtTransactionCategory.joins(:at_grouped_category).where(before_version_id: at_transaction_category_id, at_grouped_categories: {version: @latest_version})
      return at_transaction_category[0].id
    end
  end

  # アプリのカテゴリバージョンのカテゴリIDとカテゴリ名１、カテゴリ名２の連想配列を作る。
  # 例）{272=>{"category_name1"=>"食費", "category_name2"=>"食費"}}
  def category_name_map
    category = Entities::AtTransactionCategory.joins(:at_grouped_category).where(at_grouped_categories: {version: @category_version})
    category.map{ |category| [category['id'], {category_name1: category[:category_name1], category_name2: category[:category_name2]}]}.to_h
  end

  # 指定バージョンの未分類(at_category_id:0000)のカテゴリ情報を返す
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
  # 指定バージョンのカテゴリ情報を返す
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
