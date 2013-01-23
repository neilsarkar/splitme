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
    it "does not charge the card if the plan user has no merchant account" do
      commitment = FactoryGirl.create(:commitment)
      commitment.plan.user.stub(has_bank_account?: false)
      commitment.charge!.should be_false
      commitment.should be_unpaid
    end

    it "charges the card and saves the debit uri" do
      commitment = FactoryGirl.create(:commitment)
      buyer = stub
      buyer.should_receive(:debit).
        with({
          amount: commitment.plan.price_per_person_with_fees,
          appears_on_statement_as: commitment.plan.statement_title,
          merchant_uri: commitment.plan.user.balanced_account_uri
        }).and_return(stub(uri: "/debit/abcd"))
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
        running {
          commitment.charge!
        }.should raise_error
        commitment.state.should == "failed"
      end
    end
  end
end
