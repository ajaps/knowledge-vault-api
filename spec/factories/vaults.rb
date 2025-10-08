FactoryBot.define do
  factory :vault do
    association :user
    name { "Vault" }
    description { "Desc" }
  end
end