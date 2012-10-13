FactoryGirl.define do
  sequence(:bank_account_number) { |n| "#{1234521340 + n}" }
  sequence(:phone_number) { |n| "#{2120001000 + n}" }

  factory :user do
    sequence(:phone_number) { FactoryGirl.generate(:phone_number) }
    bank_account_number { FactoryGirl.generate(:bank_account_number) }
    bank_routing_number "021000021"
    sequence(:email) { |n| "user#{n}@gmail.com" }
    sequence(:name) { |n| "User #{n}" }
    password "Poopsammich66"
    street_address "162 Baraud Road"
    zip_code "10583"
    date_of_birth "7/1989"
  end

  factory :plan do
    title "Plan Party"
    description "Let's do this"
    total_price 10000
    association :user
  end

  factory :participant do
    name "Pat Nakajima"
    email "patnakajima@gmail.com"
    phone_number "1800MATTRES"
    card_type "VISA"
  end
end
