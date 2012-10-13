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
end
