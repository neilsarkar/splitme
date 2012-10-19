require "spec_helper"

describe Api::CommitmentsController do
  describe "#create" do
    before do
      @participant = FactoryGirl.create(:participant, password: "sekret")
      @plan = FactoryGirl.create(:plan)
    end

    it "should link a participant to the plan" do
      post :create, plan_token: @plan.token, participant: {
        email: @participant.email,
        password: "sekret"
      }

      response.status.should == 201
      commitment = Commitment.last
      commitment.plan.should == @plan
      commitment.participant.should == @participant
    end

    describe "failure cases" do
      it "404s if email does not exist" do
        post :create, plan_token: @plan.token, participant: {
          email: "nope@fuckno.com",
          password: "sekret"
        }

        response.status.should == 404
      end

      it "401s if password is wrong" do
        post :create, plan_token: @plan.token, participant: {
          email: @participant.email,
          password: "suuuuup"
        }

        response.status.should == 401
      end

      it "409s if participant is already in" do
        FactoryGirl.create(:commitment, participant: @participant, plan: @plan)

        post :create, plan_token: @plan.token, participant: {
          email: @participant.email,
          password: "sekret"
        }

        response.status.should == 409
      end
    end
  end

  describe "#charge" do
    context "when participant has not paid" do
      before do
        @commitment = FactoryGirl.create(:commitment)
        Commitment.
          stub(:find_by_plan_id_and_participant_id!).
          with(@commitment.plan_id.to_s, @commitment.participant_id.to_s).
          and_return(@commitment)
        @user = @commitment.plan.user
        @commitment.stub(charge!: true)
      end

      it "returns success when card is charged successfully" do
        post :charge, token: @user.token, plan_id: @commitment.plan_id, participant_id: @commitment.participant_id

        response.should be_success
      end

      it "returns errors" do
        @commitment.stub(charge!: false, errors: ["Card was declined."])
        post :charge, token: @user.token, plan_id: @commitment.plan_id, participant_id: @commitment.participant_id

        response.should be_bad_request
        json["meta"]["errors"].should == ["Card was declined."]
      end
    end

    context "when participant has paid" do
      it "returns an error" do
        commitment = FactoryGirl.create(:commitment)
        commitment.update_attribute :state, "paid"
        token = commitment.plan.user.token
        post :charge, token: token, plan_id: commitment.plan_id, participant_id: commitment.participant_id

        response.status.should == 409
        json["response"]["state"].should == "paid"
      end
    end

    context "when user is not plan creator" do
      it "returns 404 if commitment does not exist" do
        user = FactoryGirl.create(:user)

        post :charge, token: user.token, plan_id: 1234, participant_id: 5678

        response.status.should == 404
      end

      it "returns 401 if user is not plan creator" do
        user = FactoryGirl.create(:user)
        commitment = FactoryGirl.create(:commitment)

        post :charge, token: user.token, plan_id: commitment.plan_id, participant_id: commitment.participant_id

        response.status.should == 401
      end
    end
  end
end
