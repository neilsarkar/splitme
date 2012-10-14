require 'spec_helper'

describe Plan do
  describe "validations" do
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

    it "does not allow both total price and price per person" do
      plan = FactoryGirl.build(:plan, total_price: 10000, price_per_person: 10000)
      plan.should_not be_valid
      plan.should have_at_least(1).error_on(:price)

      plan.price_per_person = nil
      plan.should be_valid
    end
  end

  describe "#before_create" do
    it "sets token" do
      plan = FactoryGirl.build(:plan)
      String.should_receive(:random_alphanumeric).with(20).and_return("TOKEN")
      plan.token.should be_nil
      plan.save
      plan.token.should == "TOKEN"
    end
  end

  describe "price calculations" do
    describe "#total_price" do
      it "reads attribute when set" do
        plan = Plan.new(total_price: 10000)
        plan.total_price.should == 10000
      end

      it "calculates from price per person when not set" do
        plan = Plan.new(price_per_person: 1000)
        plan.stub(participants: [1,2,3,4])
        plan.total_price.should == 5000
      end
    end

    describe "#price_per_person" do
      it "reads attribute when set" do
        plan = Plan.new(price_per_person: 1000)
        plan.price_per_person.should == 1000
      end

      it "calculates from price per person when not set" do
        plan = Plan.new(total_price: 1000)
        plan.stub(participants: [1,2])
        plan.price_per_person.should == 333
      end
    end

    describe "#total_price_string" do
      it "presents a dollar representation" do
        plan = Plan.new(total_price: 10000)
        plan.total_price_string.should == "$100.00"
      end
    end

    describe "#price_per_person_string" do
      it "presents a dollar representation" do
        plan = Plan.new(price_per_person: 10000)
        plan.price_per_person_string.should == "$100.00"
      end
    end

    describe "#total_price=" do
      it "passes integers through" do
        plan = Plan.new(total_price: 4000)
        plan.total_price.should == 4000
      end

      it "ignores symbols" do
        plan = Plan.new(total_price: "$4,000")
        plan.total_price.should == 400000
      end

      it "processes decimals" do
        plan = Plan.new(total_price: "$29.99")
        plan.total_price.should == 2999
      end
    end

    describe "#price_per_person=" do
      it "passes integers through" do
        plan = Plan.new(price_per_person: 4000)
        plan.price_per_person.should == 4000
      end

      it "ignores symbols" do
        plan = Plan.new(price_per_person: "$4,000")
        plan.price_per_person.should == 400000
      end

      it "processes decimals" do
        plan = Plan.new(price_per_person: "$29.99")
        plan.price_per_person.should == 2999
      end
    end
  end
end
