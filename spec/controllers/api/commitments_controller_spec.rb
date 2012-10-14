require "spec_helper"

describe Api::CommitmentsController do
  describe "#collect" do
    context "when participant has not paid" do
      before do
        @commitment = FactoryGirl.create(:commitment)
        Commitment.
          stub(:find_by_plan_id_and_participant_id!).
          with(@commitment.plan_id.to_s, @commitment.participant_id.to_s).
          and_return(@commitment)
        @user = @commitment.plan.user
        @commitment.stub(collect!: true)
      end

      it "returns success when card is charged successfully" do
        post :collect, token: @user.token, plan_id: @commitment.plan_id, participant_id: @commitment.participant_id

        response.should be_success
      end

      it "returns errors" do
        @commitment.stub(collect!: false, errors: ["Card was declined."])
        post :collect, token: @user.token, plan_id: @commitment.plan_id, participant_id: @commitment.participant_id

        response.should be_bad_request
        json["meta"]["errors"].should == ["Card was declined."]
      end
    end

    context "when participant has paid" do
      it "returns an error" do
        commitment = FactoryGirl.create(:commitment)
        commitment.update_attribute :state, "paid"
        token = commitment.plan.user.token
        post :collect, token: token, plan_id: commitment.plan_id, participant_id: commitment.participant_id

        response.status.should == 409
      end
    end
  end
end
