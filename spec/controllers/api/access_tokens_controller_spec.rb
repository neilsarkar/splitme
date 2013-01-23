require "spec_helper"

describe Api::AccessTokensController do
  describe "#from_groupme_token" do
    it "returns user data if authentication is successful" do
      user = FactoryGirl.create(:user)
      converter = stub(user: user, process: true)
      UserConverter.should_receive(:new).with("TOKEN")
        .and_return(converter)

      post :from_groupme_token, json: {
        groupme_token: "TOKEN"
      }
      response.should be_success
      json["response"]["token"].should == user.token
    end

    it "passes along user creation errors" do
      user = stub(errors: stub(full_messages: ["Ya", "Burnt"]))
      converter = stub(user: user, process: false)
      UserConverter.should_receive(:new).with("TOKEN")
        .and_return(converter)

      post :from_groupme_token, json: {
        groupme_token: "TOKEN"
      }

      response.status.should == 400
      json["meta"]["errors"].should == ["Ya and Burnt"]
    end

    it "returns 401 if token is invalid" do
      converter = stub(user: nil, process: false)
      UserConverter.should_receive(:new).with("TOKEN")
        .and_return(converter)
      post :from_groupme_token, json: {
        groupme_token: "TOKEN"
      }
      response.status.should == 401
      response.body.should be_blank
    end
  end
end
