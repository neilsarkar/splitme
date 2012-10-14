require 'spec_helper'

describe Commitment do
  describe "validations" do
    it "requires plan" do
      commitment = FactoryGirl.build(:commitment, :plan => nil)
      commitment.should_not be_valid
      commitment.should have_at_least(1).error_on(:plan_id)
    end

    it "requires participant" do
      commitment = FactoryGirl.build(:commitment, :participant => nil)
      commitment.should_not be_valid
      commitment.should have_at_least(1).error_on(:participant_id)
    end

    it "does not allow participant to commit multiple times" do
      commitment = FactoryGirl.create(:commitment)
      double_commitment = Commitment.new(plan_id: commitment.plan_id, participant_id: commitment.participant_id)
      double_commitment.should_not be_valid
      double_commitment.should have_at_least(1).error_on :participant_id
    end
  end
end
