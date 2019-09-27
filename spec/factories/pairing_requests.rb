FactoryBot.define do
  factory :pairing_request, :class => Entities::PairingRequest do
    from_user_id     { nil }
    to_user_id       { nil }
    group_id         { nil }
    token            { "test" }
    token_expires_at { "2019/12/31 23:59:59" }
    status           { 0 }
  end
end