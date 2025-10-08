FactoryBot.define do
  factory :membership do
    user
    vault
    role { :reader }
  end
end