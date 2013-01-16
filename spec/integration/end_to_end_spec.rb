# This exercises a full splitme transaction from start to end.
#
# This is probably bad practice.
#
# It's kind of nice to have now, but should be ripped out as the service expands.
#
# If this is still here by summer of 2013, everyone should be fired.

require "spec_helper"

describe "splitme" do
  include EmailSpec::Matchers

  it "works" do
    # Client creates a user
    user = post "/users", {
      name: "Cameron Hunt",
      email: "cam@hunt.io",
      phone_number: "+1 2121231234",
      password: "sekret",
      bank_routing_number: "021000021",
      bank_account_number: "969199879",
      street_address: "162 Baraud Rd",
      zip_code: "90210",
      date_of_birth: "01/1984"
    }

    @response.code.should == 201
    token = user["token"]
    user["has_bank_account"].should be

    # Client creates a plan
    post "/plans?token=#{token}", {
      title: "Ski House",
      description: "Come hang out with me",
      total_price: "$100"
    }
    @response.code.should == 201

    # Client can view that plan
    plans = get "/plans?token=#{token}"
    id = plans.first["id"]
    plan = get "/plans/#{id}?token=#{token}"
    plan_token = plan["token"]

    # New user visits link
    visit "/#{plan_token}"
    page.should have_content("Ski House")

    # New user enters credit card info
    fill_in "js-email", with: "neil@neilsarkar.com"
    fill_in "js-name", with: "Neil Sarkar"
    fill_in "js-phone-number", with: "9173706969"
    fill_in "js-card-number", with: "4012888888881881"
    fill_in "js-expiration-month", with: "01"
    fill_in "js-expiration-year", with: "2016"
    fill_in "js-password", with: "sekret"
    click_button "I'm in"
    page.should have_content("Awesome, you're in.")

    # Organizer receives an email
    email = Pony.deliveries.last
    email.should be_delivered_to "cam@hunt.io"
    email.should cc_to "neil@neilsarkar.com"
    email.should have_subject "Ski House"
    email.should have_body_text "Neil Sarkar is in."

    # Existing user validates via sign in
    user = FactoryGirl.create(:buyer_user, name: "Joey Pfeifer", email: "joey@pfeifer.com", password: "sekret")
    visit "/#{plan_token}"
    page.should have_content("Ski House")
    click_link "I have a password and want to sign in"
    fill_in "email", with: user.email
    fill_in "password", with: "sekret"
    click_button "I'm in"
    page.should have_content("Awesome, you're in.")

    # Organizer receives an email
    email = Pony.deliveries.last
    email.should be_delivered_to "cam@hunt.io"
    email.should cc_to ["joey@pfeifer.com","neil@neilsarkar.com"]
    email.should have_subject "Ski House"
    email.should have_body_text "Joey Pfeifer is in."

    # Client charges cards
    plan = get "/plans/#{id}?token=#{token}"
    plan["participants"].size.should == 2
    neil = plan["participants"].first
    joey = plan["participants"].last
    post "/plans/#{id}/charge/#{neil["id"]}?token=#{token}"
    @response.code.should == 201
    Balanced::FakeAccount.any_instance.stub(:debit).and_return(false)
    post "/plans/#{id}/charge/#{joey["id"]}?token=#{token}"
    @response.code.should == 400

    # Client recharges a card that failed once
    Balanced::FakeAccount.any_instance.unstub(:debit)
    post "/plans/#{id}/charge/#{joey["id"]}?token=#{token}"
    @response.code.should == 201

    balanced_user = stub
    Balanced::Account.should_receive(:find_by_email).
      with("cam@hunt.io").
      and_return(balanced_user)
    balanced_user.should_receive(:credit).with({
      amount: 6666,
      appears_on_statement_as: "SplitMe: SkiHouse"
    })

    # Client collects
    post "/plans/#{id}/collect?token=#{token}"
    @response.code.should == 200

    # Participants receive a confirmation email
    email = Pony.deliveries.last
    email.should be_delivered_to "cam@hunt.io"
    email.should cc_to ["joey@pfeifer.com","neil@neilsarkar.com"]
    email.should have_subject "Ski House"
    email.should have_body_text "It's on."
    email.should have_body_text "Each person paid $33.33"

    # Client destroys the plan
    post "/plans/#{id}/destroy?token=#{token}"
    @response.code.should == 200

    Plan.find_by_id(id).should be_nil
  end
end
