require 'spec_helper'

describe Plan do
  it "requires title" do
    plan = FactoryGirl.build(:plan, :title => nil)
    plan.should_not be_valid
    plan.should have_at_least(1).error_on(:title)
  end

  it "requires either total price or price per person" do
    plan = FactoryGirl.build(:plan, total_price: nil, price_per_person: nil)
    plan.should_not be_valid
    plan.should have_at_least(1).error_on(:price)

    plan.total_price = 10000
    plan.should be_valid

    plan.total_price = nil
    plan.price_per_person = 1000
    plan.should be_valid
  end
end
