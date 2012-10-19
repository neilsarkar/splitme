require "spec_helper"

describe Api::ParticipantsController do
  it "#create" do
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
end
