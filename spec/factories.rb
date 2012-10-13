FactoryGirl.define do
  sequence(:bank_account_number) { |n| "#{1234521340 + n}" }
  sequence(:phone_number) { |n| "#{2120001000 + n}" }

  factory :user do |user|
    user.sequence(:phone_number) { FactoryGirl.generate(:phone_number) }
    user.bank_account_number { FactoryGirl.generate(:bank_account_number) }
    user.bank_routing_number "021000021"
    user.sequence(:email) { |n| "user#{n}@gmail.com" }
    user.sequence(:name) { |n| "User #{n}" }
    user.password "Poopsammich66"
    user.street_address "162 Baraud Road"
    user.zip_code "10583"
    user.date_of_birth "7/1989"
  end

  factory :plan do |plan|
    plan.title "Plan Party"
    plan.description "Let's do this"
    plan.total_price 10000
    plan.association :user
  end
end
