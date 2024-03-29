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

    it "requires password" do
      user = FactoryGirl.build(:user, :password => nil)
      user.should_not be_valid
      user.should have_at_least(1).error_on(:password)
    end

    it "does not require password if password has already been set" do
      user = FactoryGirl.create(:user, password: "sekret")

      user.reload
      user.name = "Joey"
      user.should be_valid
    end

    it "requires US phone number" do
      user = FactoryGirl.build(:user, phone_number: "+44 1231234")
      user.should_not be_valid
      user.errors.messages[:phone_number].should include "must be in the U.S."

      user.phone_number = "2120001000"
      user.valid?
      user.errors.messages[:phone_number].should be_blank
    end

    it "requires valid email" do
      user = FactoryGirl.build(:user, email: "neil")
      user.should_not be_valid
      user.errors.messages[:email].should include "must be a valid format"

      user.email = "neil@groupme.com"
      user.valid?
      user.errors.messages[:email].should be_blank
    end
  end

  it "does not use case sensitive emails" do
    user = FactoryGirl.create(:user, email: "NeIl@gmail.com")
    User.find_by_email("neil@gmail.com").should == user
  end

  it "accepts a password" do
    user = FactoryGirl.create(:user, password: "gunit")
    User.find_by_email(user.email).authenticate("gunit").should == user
  end

  describe "balanced payments integration" do
    before do
      @marketplace = stub
      Balanced::Marketplace.stub(:mine).and_return(@marketplace)
      @marketplace.stub(:create_bank_account).with(
        account_number: "1234567890",
        bank_code: "321174851",
        name: "Neil Sarkar"
      ).and_return(
        stub({
          uri: "http://balancedpayments.com/bank_uri"
        })
      )
    end

    context "when user has no balanced account" do
      it "creates a merchant account when bank info is passed" do
        @marketplace.should_receive(:create_merchant).with(
          email_address: "neil@groupme.com",
          merchant: {
            type: "person",
            name: "Neil Sarkar",
            phone_number: "+12121231234",
            street_address: "1600 Pennsylvania Avenue",
            postal_code: "90210",
            dob: "1984-01"
          },
          bank_account_uri: "http://balancedpayments.com/bank_uri",
          name: "Neil Sarkar"
        ).and_return(stub(uri: "http://balancedpayments.com/account_uri"))

        user = FactoryGirl.build(:user, {
          email: "neil@groupme.com",
          name: "Neil Sarkar",
          phone_number: "12121231234",
          bank_account_number: "1234567890",
          bank_routing_number: "321174851",
          street_address: "1600 Pennsylvania Avenue",
          zip_code: "90210",
          date_of_birth: "1/1984"
        })
        user.save
        user.balanced_account_uri.should == "http://balancedpayments.com/account_uri"
      end

      it "creates a merchant account when bank uri is passed" do
        @marketplace.should_receive(:create_merchant).with(
          email_address: "neil@groupme.com",
          merchant: {
            type: "person",
            name: "Neil Sarkar",
            phone_number: "+12121231234",
            street_address: "1600 Pennsylvania Avenue",
            postal_code: "90210",
            dob: "1984-01"
          },
          bank_account_uri: "http://balancedpayments.com/bank_uri",
          name: "Neil Sarkar"
        ).and_return(stub(uri: "http://balancedpayments.com/account_uri"))

        user = FactoryGirl.build(:user, {
          email: "neil@groupme.com",
          name: "Neil Sarkar",
          phone_number: "12121231234",
          street_address: "1600 Pennsylvania Avenue",
          zip_code: "90210",
          date_of_birth: "1/1984",
          bank_account_uri: "http://balancedpayments.com/bank_uri"
        })
        user.save
        user.balanced_account_uri.should == "http://balancedpayments.com/account_uri"
      end

      it "creates a buyer account when card uri is passed" do
        @marketplace.should_receive(:create_buyer).with(
          email_address: "neil@groupme.com",
          card_uri: "http://balancedpayments.com/mycard",
          name: "Neil Sarkar"
        ).and_return(stub(uri: "http://balancedpayments.com/account_uri"))

        user = FactoryGirl.create(:user, {
          email: "neil@groupme.com",
          name: "Neil Sarkar",
          phone_number: "12121231234",
          card_uri: "http://balancedpayments.com/mycard"
        })
        user.balanced_account_uri.should == "http://balancedpayments.com/account_uri"
      end
    end

    context "when user has a buyer account" do
      before do
        @user = FactoryGirl.create(:user, {
          balanced_account_uri: "http://balancedpayments.com/account"
        })
        @account = stub(cards: [])
        Balanced::Account.should_receive(:find_by_email).
          with(@user.email).and_return(@account)
      end

      it "promotes to merchant when bank info is passed" do
        @account.should_receive(:promote_to_merchant).with(
          {
            type: "person",
            name: "Neil Sarkar",
            phone_number: "+12121231234",
            street_address: "1600 Pennsylvania Avenue",
            postal_code: "90210",
            dob: "1984-01"
          }
        )
        @account.should_receive(:add_bank_account).
          with("http://balancedpayments.com/bank_uri")

        @user.update_attributes({
          name: "Neil Sarkar",
          phone_number: "12121231234",
          bank_account_number: "1234567890",
          bank_routing_number: "321174851",
          street_address: "1600 Pennsylvania Avenue",
          zip_code: "90210",
          date_of_birth: "1/1984"
        })
      end

      it "promotes to merchant when bank uri is passed" do
        @account.should_receive(:promote_to_merchant).with(
          {
            type: "person",
            name: "Neil Sarkar",
            phone_number: "+12121231234",
            street_address: "1600 Pennsylvania Avenue",
            postal_code: "90210",
            dob: "1984-01"
          }
        )
        @account.should_receive(:add_bank_account).
          with("http://balancedpayments.com/bank_uri")

        @user.update_attributes({
          bank_account_uri: "http://balancedpayments.com/bank_uri",
          name: "Neil Sarkar",
          phone_number: "12121231234",
          street_address: "1600 Pennsylvania Avenue",
          zip_code: "90210",
          date_of_birth: "1/1984"
        })
     end

      it "adds card when card_uri is passed" do
        @account.should_receive(:add_card).
          with("http://balancedpayments.com/card_uri")
        @user.update_attributes({
          card_uri: "http://balancedpayments.com/card_uri"
        })
      end

      it "does not add card when card_uri is already associated with the user" do
        @account.stub(cards: [stub(id: "card_uri")])
        @account.should_not_receive(:add_card)
        @user.update_attributes({
          card_uri: "http://balancedpayments.com/card_uri"
        })
      end
    end

    context "when user has a merchant account" do
      before do
        @user = FactoryGirl.create(:merchant_user, name: "Neil Sarkar")
        @account = stub(cards: [])
        @user.stub(balanced_account: @account)
      end

      it "changes bank account when bank info is passed" do
        @account.should_receive(:add_bank_account).
          with("http://balancedpayments.com/bank_uri")

        @account.should_not_receive(:promote_to_merchant)

        @user.bank_account_uri.should_not be_blank
        @user.update_attributes({
          name: "Neil Sarkar",
          phone_number: "12121231234",
          bank_account_number: "1234567890",
          bank_routing_number: "321174851",
          street_address: "1600 Pennsylvania Avenue",
          zip_code: "90210",
          date_of_birth: "1/1984"
        })
      end

      it "changes bank account when bank uri is passed" do
        @account.should_receive(:add_bank_account).
          with("http://balancedpayments.com/bank_uri")

        @account.should_not_receive(:promote_to_merchant)

        @user.update_attributes({
          bank_account_uri: "http://balancedpayments.com/bank_uri"
        })
      end

      it "adds card when card_uri is passed" do
        @account.should_receive(:add_card).
          with("http://balancedpayments.com/card_uri")
        @user.update_attributes({
          card_uri: "http://balancedpayments.com/card_uri"
        })
      end
    end

    it "surfaces bank account creation errors" do
      error = Exception.new
      error.stub(message: "Balanced::BadRequest(400)::Bad Request:: POST https://api.balancedpayments.com/v1/marketplaces/MP3Cm5EGcLGKWXDNsMvn8RvQ/bank_accounts: request: Invalid field [bank_code] - \"0\" must have length >= 9 Your request id is OHM17c932de1a2911e29dfc026ba7cd33d0.")
      error.stub(body: {
        "description" => "Invalid field [bank_code] - \"0\" must have length >= 9 Your request id is OHM17c932de1a2911e29dfc026ba7cd33d0."
      })

      Balanced::Marketplace.mine.should_receive(:create_bank_account).and_raise(error)

      user = FactoryGirl.build(:user, {
        email: "neil@groupme.com",
        name: "Neil Sarkar",
        phone_number: "12121231234",
        bank_account_number: "1234567890",
        bank_routing_number: "0",
        street_address: "1600 Pennsylvania Avenue",
        zip_code: "90210",
        date_of_birth: "1/1984"
      })

      user.save
      user.should_not be_persisted
      user.errors[:bank_account].should == ["Invalid field [bank_code] - \"0\" must have length >= 9 Your request id is OHM17c932de1a2911e29dfc026ba7cd33d0."]
    end
  end

  describe "on creation" do
    it "creates a token when user is created" do
      String.should_receive(:random_alphanumeric).with(40).and_return("TOKEN")

      user = FactoryGirl.build(:user)
      user.save
      user.token.should == "TOKEN"
    end
  end

  describe "#phone_number=" do
    it "formats as US" do
      user = User.new
      user.phone_number = "(917) 370-6969"
      user.phone_number.should == "19173706969"
    end
  end

  describe "#email=" do
    it "downcases email" do
      user = User.new
      user.email = "NEIL@GMAIL.COM"
      user.email.should == "neil@gmail.com"
    end

    it "does not blow up on nil" do
      user = User.new
      running {
        user.email = nil
      }.should_not raise_error
    end
  end

  describe "#find_by_email!" do
    it "finds by downcased email" do
      user = FactoryGirl.create(:user, email: "neil@gmail.com")
      User.find_by_email!("NEIL@GMAIL.COM").should == user
      running {
        User.find_by_email!("nope@fake.com")
      }.should raise_error
    end
  end

  describe "#to_json" do
    it "returns token, has_bank_account, and has_card" do
      user = FactoryGirl.create(:user)

      json = Yajl::Parser.parse(user.to_json)
      json["token"].should == user.token
      json["has_bank_account"].should be_false
      json["has_card"].should be_false
      json["name"].should == user.name
    end
  end
end
