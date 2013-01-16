require "spec_helper"

describe Api::UsersController do
  describe "#create" do
    it "creates a user" do
      user = FactoryGirl.build(:user)
      User.should_receive(:new).with("name" => "Neil Sarkar").and_return(
        stub(save: true, to_json: {"cool" => "nice"}.to_json)
      )

      post :create, json: {
        user: { name: "Neil Sarkar" }
      }

      response.status.should == 201
      json["response"]["cool"].should == "nice"
    end

    it "returns errors" do
      user = FactoryGirl.build(:user)
      errors = stub(full_messages: ["You're", "burnt"])
      User.any_instance.stub(save: false, errors: errors)
      post :create, json: { name: "Neil Sarkar" }

      response.should be_bad_request
      json["meta"]["errors"].should == ["You're and burnt"]
    end
  end

  describe "#update" do
    before do
      @user = FactoryGirl.create(:user)
      User.stub(:find_by_token).and_return(nil)
      User.stub(:find_by_token).with("token").and_return(@user)
    end

    it "returns 200 after updating user" do
      @user.should_receive(:update_attributes).with({"name" => "Neil Sarkar"})
        .and_return(true)
      post :update, token: "token", json: { user: { name: "Neil Sarkar" } }
      response.should be_success
    end

    it "returns errors" do
      errors = stub(full_messages: ["You're", "burnt"])
      @user.stub(update_attributes: false, errors: errors)
      post :update, token: "token", json: { user: { name: "Neil Sarkar" } }

      response.should be_bad_request
      json["meta"]["errors"].should == ["You're and burnt"]
    end

    it "401s if token is invalid" do
      post :update, token: "PRETEND", json: {}

      response.status.should == 401
    end
  end

  describe "#authenticate" do
    it "returns 404 if user does not exist" do
      post :authenticate, json: {
        user: { email: "neil@groupme.com", password: "nice" }
      }

      response.status.should == 404
    end

    it "returns 401 if password is incorrect" do
      user = FactoryGirl.create(:user, email: "neil@groupme.com", password: "gunit")
      post :authenticate, json: {
        user: { email: "neil@groupme.com", password: "nice" }
      }

      response.status.should == 401
    end

    it "returns user data if authentication is successful" do
      user = FactoryGirl.create(:user, email: "neil@groupme.com", password: "gunit")
      post :authenticate, json: {
        user: { email: "neil@groupme.com", password: "gunit" }
      }

      response.should be_success
      json["response"]["token"].should == user.token
    end
  end

  describe "#me" do
    it "returns user data if authentication is successful" do
      user = FactoryGirl.create(:user)
      get :me, token: user.token

      response.should be_success
      json["response"]["name"].should == user.name
    end
  end
end
