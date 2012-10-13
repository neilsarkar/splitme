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

    it "requires US phone number" do
      user = FactoryGirl.build(:user, phone_number: "+44 1231234")
      user.should_not be_valid
      user.errors.messages[:phone_number].should include "must be in the U.S."

      user.phone_number = "2120001000"
      user.valid?
      user.errors.messages[:phone_number].should be_blank
    end
  end

  it "accepts a password" do
    user = FactoryGirl.create(:user, password: "gunit")
    User.find_by_email(user.email).authenticate("gunit").should == user
  end

  describe "on creation" do
    it "creates a token when user is created" do
      String.should_receive(:random_alphanumeric).with(40).and_return("TOKEN")

      user = FactoryGirl.build(:user)
      user.save
      user.token.should == "TOKEN"
    end

    describe "balanced payments integration" do
      it "should create a bank account" do
        Balanced::BankAccount.should_receive(:new).with(
          account_number: "1234567890",
          bank_code: "321174851",
          name: "Neil Sarkar"
        ).and_return(stub(uri: "http://balancedpayments.com/uri", save: true))

        marketplace = stub
        marketplace.should_receive(:create_merchant).with(
          "neil@groupme.com",
          {
            type: "person",
            name: "Neil Sarkar",
            phone_number: "+12121231234"
          },
          "http://balancedpayments.com/uri"
        ).and_return(stub(id: "abcdef"))

        Balanced::Marketplace.should_receive(:my_marketplace).and_return(marketplace)

        user = FactoryGirl.create(:user, {
          email: "neil@groupme.com",
          name: "Neil Sarkar",
          phone_number: "12121231234",
          bank_account_number: "1234567890",
          bank_routing_number: "321174851"
        })
        user.balanced_payments_id.should == "abcdef"
      end
    end
  end

  describe "#phone_number=" do
    it "formats as US" do
      user = User.new
      user.phone_number = "(917) 370-6969"
      user.phone_number.should == "19173706969"
    end
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
