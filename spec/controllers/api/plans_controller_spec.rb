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
      plan_json["locked"].should be_false
    end

    it "shows participants" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      commitment = FactoryGirl.create(:commitment, plan: plan)
      get :show, token: @user.token, id: plan.id

      response.should be_success
      plan_json = json["response"]
      plan_json["participants"].length.should == plan.participants.length
      plan_json["participants"][0]["name"].should == plan.participants.first.name
      plan_json["participants"][0]["email"].should == plan.participants.first.email
      plan_json["participants"][0]["phone_number"].should == plan.participants.first.phone_number
    end

    it "doesn't blow up with no participants" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :show, token: @user.token, id: plan.id

      response.should be_success

      plan_json = json["response"]
      plan_json["participants"].length.should == 0
    end

    it "shows stubbed breakdown" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :show, token: @user.token, id: plan.id

      response.should be_success

      plan_json = json["response"]
      plan_json["breakdown"].should == {
       "1" => "$100.00",
       "2" => "$50.00",
       "3" => "$33.34",
       "4" => "$25.00",
       "5" => "$20.00"
      }
    end

    it "shows plan as locked if it is locked" do
      plan = FactoryGirl.create(:plan, user: @user)
      plan.lock!
      get :show, token: @user.token, id: plan.id
      json["response"]["locked"].should be_true
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
      commitment = FactoryGirl.create(:commitment, plan: plan)
      get :preview, plan_token: plan.token

      response.should be_success
      plan_json = json["response"]
      plan_json["participants"].length.should == plan.participants.length
      plan_json["participants"][0]["name"].should == plan.participants.first.name
      plan_json["participants"][0]["email"].should == plan.participants.first.email
      plan_json["participants"][0]["phone_number"].should == plan.participants.first.phone_number
    end

    it "shows creator name" do
      plan = FactoryGirl.create(:plan)
      get :preview, plan_token: plan.token

      json["response"]["treasurer_name"].should == plan.user.name
    end

    it "returns 404 if plan cannot be found" do
      get :preview, plan_token: "PRETEND"

      response.status.should == 404
    end
  end

  describe "#collect" do
    before do
      @plan = FactoryGirl.create(:plan, total_price: 1000)
      @user = @plan.user
    end

    it "404s if user does not own plan" do
      plan = FactoryGirl.create(:plan)
      post :collect, id: plan.id, token: @user.token
      response.status.should == 404
    end

    it "collects funds and returns 200" do
      Plan.any_instance.should_receive(:collected?).and_return(false)
      Plan.any_instance.should_receive(:collect!).and_return(true)
      post :collect, id: @plan.id, token: @user.token
      response.status.should == 200
    end

    it "returns 409 if funds are already collected" do
      Plan.any_instance.should_receive(:collected?).and_return(true)
      post :collect, id: @plan.id, token: @user.token
      response.status.should == 409
    end
  end
end
