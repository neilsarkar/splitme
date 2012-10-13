require 'spec_helper'

describe Participant do
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
end
