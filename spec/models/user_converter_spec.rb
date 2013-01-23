require "spec_helper"

describe UserConverter do
  describe "#process" do
    context "when access token is invalid" do
      before do
        response = stub(success?: false)
        client = stub
        client.stub(:get).with("/users/me").and_return(response)
        GroupmeClient.stub(:new).with("TOKEN").and_return(client)
      end

      it "should return false, with no user object" do
        converter = UserConverter.new("TOKEN")
        converter.process.should be_false
        converter.user.should be_nil
      end
    end

    context "when access token is valid" do
      before do
        response = stub(success?: true, response: {
          user: {
            "id" => "66",
            "name"  => "Neil Sarkar",
            "email" => "neil@gmail.com",
            "phone_number" => "+1 2121231234"
          }
        })
        client = stub
        client.stub(:get).with("/users/me").and_return(response)
        GroupmeClient.stub(:new).with("TOKEN").and_return(client)
      end

      context "when groupme_user_id exists" do
        it "should return the token of the splitme user" do
          user = FactoryGirl.create(:user, groupme_user_id: 66)
          converter = UserConverter.new("TOKEN")
          converter.process.should be_true
          converter.user.should == user
        end
      end

      context "when groupme_user_id does not exist" do
        it "should create a new splitme user" do
          converter = UserConverter.new("TOKEN")
          running {
            converter.process.should be_true
          }.should change { User.count }.by(1)
          converter.user.should == User.last
          converter.user.name.should == "Neil Sarkar"
          converter.user.email.should == "neil@gmail.com"
          converter.user.phone_number.should == "12121231234"
          converter.user.groupme_user_id.should == "66"
          converter.user.groupme_access_token.should == "TOKEN"
        end

        it "should return false if user cannot be created" do
          # e.g. Email is taken
          converter = UserConverter.new("TOKEN")
          User.any_instance.should_receive(:save).and_return(false)
          converter.process.should be_false
        end
      end
    end
  end
end
