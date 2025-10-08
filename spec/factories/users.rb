FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "u#{n}@mail.io" }
    password { "password" }
    
    after(:create) do |user|
      ApiKey.generate!(user)
    end
  end
end