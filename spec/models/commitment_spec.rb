require 'spec_helper'

describe Commitment do
  describe "validations" do
    it "requires plan" do
      commitment = FactoryGirl.build(:commitment, :plan => nil)
      commitment.should_not be_valid
      commitment.should have_at_least(1).error_on(:plan_id)
    end

    it "requires user" do
      commitment = FactoryGirl.build(:commitment, :user => nil)
      commitment.should_not be_valid
      commitment.should have_at_least(1).error_on(:user_id)
    end

    it "does not allow user to commit multiple times" do
      commitment = FactoryGirl.create(:commitment)
      double_commitment = Commitment.new(plan_id: commitment.plan_id, user_id: commitment.user_id)
      double_commitment.should_not be_valid
      double_commitment.should have_at_least(1).error_on :user_id
    end
  end

  describe "#charge!" do
    it "charges the card and saves the debit uri" do
      commitment = FactoryGirl.create(:commitment)
      buyer = stub
      buyer.should_receive(:debit).
        with(commitment.plan.price_per_person_with_fees, commitment.plan.title).
        and_return(stub(uri: "/debit/abcd"))
      Balanced::Account.should_receive(:find_by_email).
        with(commitment.user.email).
        and_return(buyer)
      commitment.charge!
      commitment.debit_uri.should == "/debit/abcd"
    end

    it "updates the state of the commitment" do
      commitment = FactoryGirl.create(:commitment)
      commitment.charge!
      commitment.state.should == "escrowed"
    end

    it "locks the plan" do
      commitment = FactoryGirl.create(:commitment)
      commitment.charge!
      commitment.plan.should be_locked
    end

    context "failure" do
      it "updates state to 'failed'" do
        commitment = FactoryGirl.create(:commitment)
        Balanced::Account.stub(:find_by_email).
          with(commitment.user.email).
          and_raise(Balanced::Error)
        commitment.charge!
        commitment.state.should == "failed"
      end
    end
  end
end
