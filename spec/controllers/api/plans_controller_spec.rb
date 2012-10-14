require "spec_helper"

describe Api::PlansController do
  before do
    @user = FactoryGirl.create(:user)
  end

  describe "#create" do
    it "creates a plan" do
      running {
        post :create, token: @user.token, json: {
          plan: {
            title: "Ski House",
            total_price: "100"
          }
        }
      }.should change { Plan.count }.by(1)

      plan = Plan.last
      plan.user.should == @user

      response.status.should == 201
      json["response"]["id"].should == plan.id
    end
  end

  describe "#index" do
    it "shows all plans for current user" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :index, token: @user.token

      response.should be_success
      plan_json = json["response"][0]
      plan_json["title"].should == plan.title
      plan_json["description"].should == plan.description
      plan_json["total_price"].should == "$400.00"
    end
  end

  describe "#show" do
    it "shows an individual plan" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :show, token: @user.token, id: plan.id

      response.should be_success
      plan_json = json["response"]
      plan_json["title"].should == plan.title
      plan_json["description"].should == plan.description
      plan_json["total_price"].should == "$400.00"
      plan_json["price_per_person"].should == plan.price_per_person_string
      plan_json["token"].should == plan.token
    end

    it "shows participants" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :show, token: @user.token, id: plan.id

      response.should be_success
      plan_json = json["response"]
      plan_json["participants"].length.should == plan.participants.length
      plan_json["participants"][0]["name"].should == plan.participants.first.name
      plan_json["participants"][0]["email"].should == plan.participants.first.email
      plan_json["participants"][0]["phone_number"].should == plan.participants.first.phone_number
    end

    it "returns 404 if the user does not own the plan" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :show, token: @user.token, id: plan.id

      response.should be_success
      plan_json = json["response"]
      plan_json["title"].should == plan.title
      plan_json["description"].should == plan.description
      plan_json["total_price"].should == "$400.00"
    end
  end

  describe "#collect" do
    it "returns 200 if collection is successful" do
      plan = FactoryGirl.create(:plan, user: @user)
      Plan.any_instance.should_receive(:collect!).and_return(true)

      post :collect, token: @user.token, id: plan.id, participant_id: 1

      response.should be_success
    end

    it "returns errors if collection fails" do
      plan = FactoryGirl.create(:plan, user: @user)
      Plan.any_instance.should_receive(:collect!).and_return(false)

      post :collect, token: @user.token, id: plan.id, participant_id: 1
      response.should be_bad_request
    end
  end

  describe "#preview" do
    it "shows an individual plan" do
      plan = FactoryGirl.create(:plan, total_price: 40000)
      get :preview, plan_token: plan.token

      response.should be_success
      plan_json = json["response"]
      plan_json["title"].should == plan.title
      plan_json["description"].should == plan.description
      plan_json["total_price"].should == "$400.00"
      plan_json["price_per_person"].should == plan.price_per_person_string
      plan_json["token"].should == plan.token
    end

    it "shows participants" do
      plan = FactoryGirl.create(:plan, total_price: 40000)
      get :preview, plan_token: plan.token

      response.should be_success
      plan_json = json["response"]
      plan_json["participants"].length.should == plan.participants.length
      plan_json["participants"][0]["name"].should == plan.participants.first.name
      plan_json["participants"][0]["email"].should == plan.participants.first.email
      plan_json["participants"][0]["phone_number"].should == plan.participants.first.phone_number
    end

    it "returns 404 if plan cannot be found" do
      get :preview, plan_token: "PRETEND"

      response.status.should == 404
    end
  end

  describe "#join" do
    it "creates a participant" do
      plan = FactoryGirl.create(:plan)

      post :join, plan_token: plan.token, json: {
        participant: {
          name: "Neil Sarkar",
          email: "neil@groupme.com",
          phone_number: "9173706969",
          card_uri: "https://balancedpayments.com/nice"
        }
      }

      response.status.should == 201

      participant = Participant.last

      participant.name.should == "Neil Sarkar"
      participant.email.should == "neil@groupme.com"
      participant.phone_number.should == "9173706969"
      participant.card_uri.should == "https://balancedpayments.com/nice"
      plan.reload.participants.should include participant
    end
  end
end
