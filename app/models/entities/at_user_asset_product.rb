class Entities::AtUserAssetProduct < ApplicationRecord
  has_many :at_user_products, dependent: :destroy

  ASSETS_PRODUCT_NAME = {
    "SAL" => "株式全体",
    "SJP" => "国内株式",
    "SOV" => "海外株式",
    "SET" => "その他株式",
    "BAL" => "債券全体",
    "BJP" => "国内債権",
    "BOV" => "海外債権",
    "BET" => "その他債権",
    "IAL" => "投資信託全体",
    "IJP" => "国内投資信託",
    "IOV" => "国外投資信託",
    "IET" => "その他投資信託",
    "GAL" => "金貴金属",
    "ETC" => "その他"
  }
end