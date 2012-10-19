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

    describe "#price_per_person_with_fees" do
      it "should be price per person plus 3% plus $1" do
        plan = Plan.new(price_per_person: 3334)
        # $1 fee = $1.00 = 100
        # 3% fee = $1.0002 = 100. Round down bc the $1 fee will cover missing cents
        plan.price_per_person_with_fees.should == 3534
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

  describe "#total_escrowed" do
    it "calculates amount from successful commitments" do
      plan = FactoryGirl.create(:plan, total_price: 10000)

      commitment_1 = FactoryGirl.create(:commitment, plan: plan)
      commitment_1.send :mark_escrowed!

      commitment_2 = FactoryGirl.create(:commitment, plan: plan)
      commitment_2.send :mark_failed!

      plan.total_escrowed.should == 3333
    end

    it "calculates amount from successful commitments for per_person plans" do
      plan = FactoryGirl.create(:plan, price_per_person: 10000, total_price: nil)

      commitment_1 = FactoryGirl.create(:commitment, plan: plan)
      commitment_1.send :mark_escrowed!

      commitment_2 = FactoryGirl.create(:commitment, plan: plan)
      commitment_2.send :mark_escrowed!

      commitment_3 = FactoryGirl.create(:commitment, plan: plan)
      commitment_3.send :mark_failed!

      commitment_4 = FactoryGirl.create(:commitment, plan: plan)
      commitment_4.send :mark_failed!

      plan.total_escrowed.should == 20000
    end
  end

  describe "#collected?" do
    it "returns true if all commitments are collected or failed" do
      plan = FactoryGirl.create(:plan, locked: true)

      plan.should_not be_collected

      commitment_1 = FactoryGirl.create(:commitment, plan: plan)
      commitment_1.mark_collected!

      commitment_2 = FactoryGirl.create(:commitment, plan: plan)
      commitment_2.send :mark_failed!

      commitment_3 = FactoryGirl.create(:commitment, plan: plan)
      commitment_3.send :mark_escrowed!

      plan.reload.should_not be_collected

      commitment_3.mark_collected!
      plan.reload.should be_collected
    end
  end

  describe "#collect!" do
    it "ticks collected on all escrowed accounts" do
      plan = FactoryGirl.create(:plan)

      commitment_1 = FactoryGirl.create(:commitment, plan: plan)
      commitment_1.send :mark_escrowed!
      commitment_2 = FactoryGirl.create(:commitment, plan: plan)
      commitment_2.send :mark_escrowed!

      plan.collect!

      commitment_1.reload.should be_collected
      commitment_2.reload.should be_collected
    end

    it "credits merchant" do
      plan = FactoryGirl.create(:plan)
      plan.stub(total_escrowed: 10000)

      merchant = stub
      merchant.should_receive(:credit).with(10000)
      Balanced::Account.should_receive(:find_by_email).with(plan.user.email).
        and_return(merchant)
      plan.collect!
    end

    context "error" do
      it "raises error from Balanced" do
        plan = FactoryGirl.create(:plan)
        commitment = FactoryGirl.create(:commitment, plan: plan)
        commitment.send :mark_escrowed!
        merchant = stub
        merchant.stub(:credit).and_raise(Balanced::Error)
        Balanced::Account.stub(:find_by_email).with(plan.user.email).
          and_return(merchant)

        running {
          plan.collect!
        }.should raise_error

        commitment.reload.should be_escrowed
      end
    end
  end
end
