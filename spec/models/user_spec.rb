require 'spec_helper'

describe User do
  describe "validations" do
    it "requires name" do
      user = FactoryGirl.build(:user, :name => nil)
      user.should_not be_valid
      user.should have_at_least(1).error_on(:name)
    end

    it "requires email" do
      user = FactoryGirl.build(:user, :email => nil)
      user.should_not be_valid
      user.should have_at_least(1).error_on(:email)
    end

    it "requires phone_number" do
      user = FactoryGirl.build(:user, :phone_number => nil)
      user.should_not be_valid
      user.should have_at_least(1).error_on(:phone_number)
    end

    it "requires bank_routing_number" do
      user = FactoryGirl.build(:user, :bank_routing_number => nil)
      user.should_not be_valid
      user.should have_at_least(1).error_on(:bank_routing_number)
    end

    it "requires bank_account_number" do
      user = FactoryGirl.build(:user, :bank_account_number => nil)
      user.should_not be_valid
      user.should have_at_least(1).error_on(:bank_account_number)
    end

    it "requires password" do
      user = FactoryGirl.build(:user, :password => nil)
      user.should_not be_valid
      user.should have_at_least(1).error_on(:password)
    end
  end

  it "creates a token when user is created" do
    String.should_receive(:random_alphanumeric).with(40).and_return("TOKEN")

    user = FactoryGirl.build(:user)
    user.save
    user.token.should == "TOKEN"
  end

  it "accepts a password" do
    user = FactoryGirl.create(:user, password: "gunit")
    User.find_by_email(user.email).authenticate("gunit").should == user
  end

  describe "#to_json" do
    it "returns the token" do
      user = FactoryGirl.create(:user)

      Yajl::Parser.parse(user.to_json).should == {
        "token" => user.token
      }
    end
  end
end
