class Entities::AtScrapingLog < ApplicationRecord
  belongs_to :at_user_bank_account, optional: true
  belongs_to :at_user_card_account, optional: true
  belongs_to :at_user_emoney_service_account, optional: true

  def self.insert(params)
    params.each do |v|
      self.create!(v)
    end
  end

end
