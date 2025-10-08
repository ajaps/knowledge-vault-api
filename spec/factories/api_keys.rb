FactoryBot.define do
  factory :api_key do
    user
    read_only { false }
    token { SecureRandom.hex(12) }
  end
end