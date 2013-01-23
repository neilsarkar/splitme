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
      plan_json["is_fixed_price"].should == true
      plan_json["price_per_person"].should == plan.price_per_person_string
      plan_json["token"].should == plan.token
      plan_json["is_locked"].should be_false
      plan_json["is_collected"].should be_false
    end

    it "shows participants" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      commitment = FactoryGirl.create(:commitment, plan: plan)
      get :show, token: @user.token, id: plan.id

      response.should be_success
      plan_json = json["response"]
      plan_json["participants"].length.should == plan.users.length
      plan_json["participants"][0]["name"].should == plan.users.first.name
      plan_json["participants"][0]["email"].should == plan.users.first.email
      plan_json["participants"][0]["phone_number"].should == plan.users.first.phone_number
      plan_json["participants"][0]["state"].should == "unpaid"
    end

    it "doesn't blow up with no participants" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :show, token: @user.token, id: plan.id

      response.should be_success

      plan_json = json["response"]
      plan_json["participants"].length.should == 0
    end

    it "shows breakdown" do
      plan = FactoryGirl.create(:plan, user: @user, total_price: 40000)
      get :show, token: @user.token, id: plan.id

      response.should be_success

      plan_json = json["response"]
      plan_json["breakdown"].should == PriceBreakdown.new(plan).result.as_json
    end

    it "shows plan as locked if it is locked" do
      plan = FactoryGirl.create(:plan, user: @user)
      plan.lock!
      get :show, token: @user.token, id: plan.id
      json["response"]["is_locked"].should be_true
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
      get :preview, id: plan.token

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
      get :preview, id: plan.token

      response.should be_success
      plan_json = json["response"]
      plan_json["participants"].length.should == plan.users.length
      plan_json["participants"][0]["name"].should == plan.users.first.name
      plan_json["participants"][0]["email"].should be_blank
      plan_json["participants"][0]["phone_number"].should be_blank
      plan_json["participants"][0]["state"].should be_blank
    end

    it "shows creator name" do
      plan = FactoryGirl.create(:plan)
      get :preview, id: plan.token

      json["response"]["treasurer_name"].should == plan.user.name
    end

    it "returns 404 if plan cannot be found" do
      get :preview, id: "PRETEND"

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

    it "returns 409 if funds are already collected" do
      Plan.any_instance.should_receive(:collected?).and_return(true)
      post :collect, id: @plan.id, token: @user.token
      response.status.should == 409
    end

    context "success" do
      before do
        Plan.any_instance.stub(:collected?).and_return(false)
        Plan.any_instance.should_receive(:collect!).and_return(true)
      end

      it "collects funds and returns 200" do
        post :collect, id: @plan.id, token: @user.token
        response.status.should == 200
      end

      it "broadcasts to the plan on successful collection" do
        broadcaster = stub
        Broadcaster.should_receive(:new).with(@plan).and_return(broadcaster)
        broadcaster.should_receive(:notify_plan_collected)

        post :collect, id: @plan.id, token: @user.token
      end
    end
  end

  describe "#destroy" do
    before do
      @plan = FactoryGirl.create(:plan, user: @user)
    end

    it "returns 404 if user doesn't own plan" do
      plan = FactoryGirl.create(:plan)
      post :destroy, id: plan.id, token: @user.token

      response.status.should == 404
    end

    it "returns 200 on successful plan destruction" do
      running {
        post :destroy, id: @plan.id, token: @user.token
      }.should change { Plan.count }.by(-1)

      response.status.should == 200
    end

    it "returns 400 if plan is locked" do
      @plan.update_attribute :locked, true

      running {
        post :destroy, id: @plan.id, token: @user.token
      }.should_not change { Plan.count }

      response.status.should == 400
      json["meta"]["errors"].should == ["Plan is locked."]
    end
  end
end
