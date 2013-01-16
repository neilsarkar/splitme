require "spec_helper"

describe "Plan Management" do
  it "shows your existing plans" do
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

    post "/plans?token=#{user["token"]}", {
      title: "Mexican Airbnb",
      description: "You boys like mex-i-co?",
      total_price: "$100"
    }

    post "/plans?token=#{user["token"]}", {
      title: "Kegs",
      description: "Let's go to Jarebs",
      total_price: "$320"
    }

    visit "/log_in"
    fill_in "js-email", with: "cam@hunt.io"
    fill_in "js-password", with: "sekret"
    click_button "Log In"

    page.should have_content("Mexican Airbnb")
    page.should have_content("You boys like mex-i-co?")
    page.should have_content("$100")

    page.should have_content("Kegs")
  end
end
