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
end
