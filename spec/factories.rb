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
  end
end
