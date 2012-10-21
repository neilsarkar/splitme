require "spec_helper"

describe Api::ParticipantsController do
  describe "#create" do
    it "creates a participant" do
      plan = FactoryGirl.create(:plan)

      post :create, plan_token: plan.token, json: {
        participant: {
          name: "Neil Sarkar",
          email: "neil@groupme.com",
          phone_number: "9173706969",
          card_uri: "https://balancedpayments.com/nice",
          password: "sekret"
        }
      }

      response.status.should == 201

      participant = Participant.last

      participant.name.should == "Neil Sarkar"
      participant.email.should == "neil@groupme.com"
      participant.phone_number.should == "9173706969"
      participant.card_uri.should == "https://balancedpayments.com/nice"
      participant.authenticate("sekret").should == participant
      plan.reload.participants.should include participant
    end

    it "notifies the group" do
      plan = FactoryGirl.create(:plan)

      Plan.should_receive(:find_by_token!).and_return(plan)

      participant = mock_model(Participant, save: true, as_json: {})
      Participant.should_receive(:new).and_return(participant)

      broadcaster = stub
      Broadcaster.should_receive(:new).with(plan).and_return(broadcaster)
      broadcaster.should_receive(:notify_plan_joined).with(participant)

      post :create, plan_token: plan.token, json: {
        participant: {
          name: "Neil Sarkar",
          email: "neil@groupme.com",
          phone_number: "9173706969",
          card_uri: "https://balancedpayments.com/nice",
          password: "sekret"
        }
      }
    end
  end
end
