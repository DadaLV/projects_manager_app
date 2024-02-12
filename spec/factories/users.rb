FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@test.com" }
    password { "Password4@" }
    password_confirmation { "Password4@" }
  end
end
