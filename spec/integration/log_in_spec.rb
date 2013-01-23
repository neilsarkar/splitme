require "spec_helper"

describe "User can log in via the web site" do
  describe "Splitme email and password login" do
    example do
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

      visit "/log_in"
      fill_in "js-email", with: "cam@hunt.io"
      fill_in "js-password", with: "nope"
      click_button "Log In"

      page.should have_content("Sorry, your email or password is incorrect.")

      fill_in "js-email", with: "cam@hunt.io"
      fill_in "js-password", with: "sekret"
      click_button "Log In"

      page.should have_content("Welcome, Cameron")
      page.current_path.should == "/plans"

      # Ensure that log in persists on page reload
      visit current_path
      page.should have_content("Welcome, Cameron")
    end
  end

  describe "Groupme access token login" do
    example do
      user = FactoryGirl.create(:user, groupme_user_id: "66")
      plan = FactoryGirl.create(:plan, user: user)

      visit "/connect_with_groupme/TOKEN"
      stub_request(:get, "#{GROUPME_API_URL}/users/me?token=TOKEN").to_return(
        body: {
          response: {
            user: {
              id: "66"
            }
          }
        }.to_json
      )
      page.should have_content("Welcome, #{user.name}")
      page.should have_content(plan.title)
    end
  end
end
