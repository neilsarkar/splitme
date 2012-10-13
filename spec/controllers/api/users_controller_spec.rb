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
end
