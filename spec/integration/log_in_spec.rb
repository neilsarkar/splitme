require "spec_helper"

describe "User can log in via the web site" do
  describe "Successful log in" do
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
      fill_in "js-password", with: "sekret"
      click_button "Log In"

      page.should have_content("Welcome, Cameron")
      page.current_path.should == "/plans"

      # Ensure that log in persists on page reload
      visit current_path
      page.should have_content("Welcome, Cameron")
    end
  end

  describe "Unsuccessful log in" do
    example do
      visit "/log_in"
      fill_in "js-email", with: "cam@hunt.io"
      fill_in "js-password", with: "sekret"
      click_button "Log In"

      page.should have_content("Sorry, your email or password is incorrect.")
    end
  end
end
