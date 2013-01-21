require "spec_helper"

describe "Managing payment information" do
  it "should allow user to add a bank account" do
    user = FactoryGirl.create(:user, password: "sekret")
    user.bank_account_uri.should be_blank

    login user, "sekret"

    click_link "Link Bank Account"

    fill_in "bank_routing_number", with: "021000021"
    fill_in "bank_account_number", with: "979689188"
    fill_in "street_address", with: "202 East 13th Street"
    fill_in "zip_code", with: "10003"
    fill_in "month", with: "01"
    fill_in "day", with: "06"
    fill_in "year", with: "1984"

    click_button "Link Bank Account"

    page.should have_content("Cool, your bank account is linked now.")

    user.reload.bank_account_uri.should_not be_blank
  end
end
