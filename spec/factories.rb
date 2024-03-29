FactoryGirl.define do
  sequence(:bank_account_number) { |n| "#{1234521340 + n}" }
  sequence(:phone_number) { |n| "#{2120001000 + n}" }

  factory :commitment do
    association :user
    association :plan
  end

  factory :plan do
    title "Plan Party"
    description "Let's do this"
    total_price 10000
    association :user, factory: :merchant_user
  end

  factory :user do
    sequence(:phone_number) { FactoryGirl.generate(:phone_number) }
    sequence(:email) { |n| "user#{n}@gmail.com" }
    sequence(:name) { |n| "User #{n}" }
    password "Poopsammich66"
  end

  factory :merchant_user, parent: :user do
    bank_account_uri "http://balancedpayments.com/old_bank_uri"
    street_address "162 Baraud Rd"
    zip_code "10583"
    date_of_birth "7/1989"
    balanced_account_uri "http://balancedpayments.com/account_uri"
  end

  factory :buyer_user, parent: :user do
    card_uri "http://balancedpayments.com/creditcard"
  end
end
