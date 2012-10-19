require 'spec_helper'

describe Participant do
  describe "validations" do
    it "requires name" do
      participant = FactoryGirl.build(:participant, :name => nil)
      participant.should_not be_valid
      participant.should have_at_least(1).error_on(:name)
    end

    it "requires email" do
      participant = FactoryGirl.build(:participant, :email => nil)
      participant.should_not be_valid
      participant.should have_at_least(1).error_on(:email)
    end

    it "requires phone_number" do
      participant = FactoryGirl.build(:participant, :phone_number => nil)
      participant.should_not be_valid
      participant.should have_at_least(1).error_on(:phone_number)
    end

    it "requires card uri" do
      participant = FactoryGirl.build(:participant, :card_uri => nil)
      participant.should_not be_valid
      participant.should have_at_least(1).error_on(:card_uri)
    end

    it "requires password" do
      participant = FactoryGirl.build(:participant, :password => nil)
      participant.should_not be_valid
      participant.should have_at_least(1).error_on(:password)
    end
  end

  describe "#before_create" do
    it "creates a Balanced buyer" do
      participant = FactoryGirl.build(:participant, :card_uri => "https://balancedpayments.com/visa")

      buyer = stub(uri: "https://balancedpayments.com/me")
      marketplace = stub(create_buyer: buyer)
      Balanced::Marketplace.should_receive(:my_marketplace).and_return(marketplace)

      participant.save
      participant.buyer_uri.should == "https://balancedpayments.com/me"
    end

    it "parses errors if Balanced creation fails" do
      participant = FactoryGirl.build(:participant, :card_uri => "https://balancedpayments.com/visa")

      error = Exception.new
      error.stub(message: {cool: "nice"}.inspect)
      marketplace = stub
      marketplace.stub(:create_buyer).and_raise(error)
      Balanced::Marketplace.should_receive(:my_marketplace).and_return(marketplace)

      participant.save.should be_false
      participant.errors[:registration].should == [error.message]
    end
  end
end
