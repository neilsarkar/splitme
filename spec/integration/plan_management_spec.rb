require "spec_helper"

describe "Plan Management" do
  it "showing your plans" do
    user = FactoryGirl.create(:user, password: "sekret")

    post "/plans?token=#{user.token}", {
      title: "Mexican Airbnb",
      description: "You boys like mex-i-co?",
      total_price: "$100"
    }

    post "/plans?token=#{user.token}", {
      title: "Kegs",
      description: "Let's go to Jarebs",
      total_price: "$320"
    }

    login(user, "sekret")
    page.should have_content("Mexican Airbnb")
    page.should have_content("You boys like mex-i-co?")
    page.should have_content("$100")

    page.should have_content("Kegs")
  end

  it "creating a plan" do
    user = FactoryGirl.create(:user, password: "sekret")
    login(user, "sekret")

    click_link "+"

    fill_in "js-description", with: "Rye House at noon"
    fill_in "js-amount", with: "$100.00"
    choose  "js-price-per-person"
    click_button "Start"

    page.should have_content("Title can't be blank")
    fill_in "js-title", with: "Team Lunch"
    click_button "Start"

    page.should have_content("Team Lunch")
    page.should have_content("Rye House at noon")
    page.should have_content("$100.00")

    plan = Plan.last
    plan.should_not be_nil
    page.should have_content("#{plan.token}")
  end

  it "collecting a plan" do
    user = FactoryGirl.create(:user, password: "sekret")
    buyer_1 = FactoryGirl.create(:user)
    buyer_2 = FactoryGirl.create(:user)

    plan = FactoryGirl.create(:plan, user: user)
    FactoryGirl.create(:commitment, plan: plan, user: buyer_1)
    FactoryGirl.create(:commitment, plan: plan, user: buyer_2)

    login(user, "sekret")
    page.should have_content("Welcome")
    visit "/plans/#{plan.id}"

    page.should have_content("4 People")

    page.should have_content("#{buyer_1.name}")
    page.should have_content("#{buyer_1.phone_number}")
    page.should have_content("#{buyer_1.email}")
    page.should have_content("#{buyer_2.name}")

    check buyer_1.name
    check buyer_2.name
    click_link "Get Money"

    # Since the user doesn't have a bank account, we prompt them to connect one.
    fill_in "bank_routing_number", with: "021000021"
    fill_in "bank_account_number", with: "979689188"
    fill_in "street_address", with: "202 East 13th Street"
    fill_in "zip_code", with: "10003"
    fill_in "month", with: "01"
    fill_in "day", with: "06"
    fill_in "year", with: "1984"
    click_button "Link Bank Account"

    # Now that they have a bank account, they should be able to collect.
    page.should have_content("Cool, your bank account is linked now.")

    check buyer_1.name
    check buyer_2.name
    click_link "Get Money"

    page.should have_css(".success")
    page.should have_no_css("input[type=checkbox]")
    click_link "Collect"

    page.should have_content("You did it!")
  end
end
