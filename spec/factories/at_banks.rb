FactoryBot.define do
  factory :at_bank, :class => Entities::AtBank do
    fnc_cd { "99999999" }
    fnc_nm { "ミロク情報銀行" }
  end
end
