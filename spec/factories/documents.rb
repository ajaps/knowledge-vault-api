FactoryBot.define do
  factory :document do
    vault
    title { "Doc" }
    body  { "Body" }
  end
end
