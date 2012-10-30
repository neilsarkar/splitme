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

  before do
    server = Capybara.current_session.driver.rack_server
    @api_root = "http://#{server.host}:#{server.port}/api"
  end

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
    email.should have_subject "Neil Sarkar is in."

    # Existing user validates via sign in
    participant = FactoryGirl.create(:participant, name: "Joey Pfeifer", email: "joey@pfeifer.com")
    visit "/#{plan_token}"
    page.should have_content("Ski House")
    click_link "I have a password and want to sign in"
    fill_in "email", with: participant.email
    fill_in "password", with: "sekret"
    click_button "I'm in"
    page.should have_content("Awesome, you're in.")

    # Organizer receives an email
    email = Pony.deliveries.last
    email.should be_delivered_to "cam@hunt.io"
    email.should cc_to ["joey@pfeifer.com","neil@neilsarkar.com"]
    email.should have_subject "Joey Pfeifer is in."

    # Client charges cards
    plan = get "/plans/#{id}?token=#{token}"
    plan["participants"].size.should == 2
    neil = plan["participants"].first
    joey = plan["participants"].last
    post "/plans/#{id}/charge/#{neil["id"]}?token=#{token}"
    @response.code.should == 201
    post "/plans/#{id}/charge/#{joey["id"]}?token=#{token}"
    @response.code.should == 201

    balanced_user = stub
    Balanced::Account.should_receive(:find_by_email).
      with("cam@hunt.io").
      and_return(balanced_user)
    balanced_user.should_receive(:credit).with(6666)

    # Client collects
    post "/plans/#{id}/collect?token=#{token}"
    @response.code.should == 200
  end

  def post(path, body={})
    @response = RestClient.post(
      "#{@api_root}#{path}",
      Yajl::Encoder.encode(body),
      { content_type: :json, accept: :json }
    )
    Yajl::Parser.parse(@response)["response"]
  end

  def get(path)
    @response = RestClient.get(
      "#{@api_root}#{path}",
      { accept: :json }
    )
    Yajl::Parser.parse(@response)["response"]
  end
end
