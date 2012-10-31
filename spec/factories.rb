FactoryGirl.define do
  sequence(:bank_account_number) { |n| "#{1234521340 + n}" }
  sequence(:phone_number) { |n| "#{2120001000 + n}" }

  factory :commitment do
    association :user
    association :plan
  end

  factory :participant do
    name "Pat Nakajima"
    email "patnakajima@gmail.com"
    phone_number "1800MATTRES"
    card_type "VISA"
    card_uri "https://balancedpayments.com/fake"
    password "sekret"
  end

  factory :plan do
    title "Plan Party"
    description "Let's do this"
    total_price 10000
    association :user
  end

  factory :user do
    sequence(:phone_number) { FactoryGirl.generate(:phone_number) }
    sequence(:email) { |n| "user#{n}@gmail.com" }
    sequence(:name) { |n| "User #{n}" }
    password "Poopsammich66"
  end

  factory :merchant_user, parent: :user do
    sequence(:bank_account_number) { FactoryGirl.generate(:bank_account_number) }
    bank_routing_number "021000021"
    street_address "162 Baraud Rd"
    zip_code "10583"
    date_of_birth "7/1989"
  end

  factory :buyer_user, parent: :user do
    card_uri "http://balancedpayments.com/creditcard"
  end
end
