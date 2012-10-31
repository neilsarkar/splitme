require "spec_helper"

describe "Joining Plan" do
  it "Shows plan details" do
    plan = FactoryGirl.create(:plan, total_price: 10000)
    commitment = FactoryGirl.create(:commitment, plan: plan)
    visit "/#{plan.token}"

    page.should have_content(plan.title)
    page.should have_content(plan.description)

    page.should have_content(plan.user.name)
    page.should have_content("2")
    page.should have_content("$50.00")
    page.should have_content("3")
    page.should have_content("$33.33")
    page.should have_content("4")
    page.should have_content("$25.00")
    page.should have_content("5")
    page.should have_content("$20.00")
    page.should have_content("6")
    page.should have_content("$16.66")

    page.find(".current").should have_content "$50.00"
    page.find(".next").should have_content "$33.33"

    page.should have_content(commitment.user.name)
  end

  it "Does not show form if plan is locked" do
    plan = FactoryGirl.create(:plan)
    plan.lock!

    visit "/#{plan.token}"

    page.should have_content(plan.title)
    page.should have_content(plan.description)

    page.should have_content(plan.user.name)
    page.should have_content("Ya burnt!")

    page.should_not have_css("form")
  end

  it "Joins the plan as a new user" do
    plan = FactoryGirl.create(:plan)
    visit "/#{plan.token}"

    page.should have_content(plan.title)

    fill_in "js-email", with: "sancho@panza.com"
    fill_in "js-name", with: "Sancho Panza"
    fill_in "js-phone-number", with: "9173706969"
    fill_in "js-card-number", with: "4012888888881881"

    fill_in "js-expiration-month", with: "01"
    fill_in "js-expiration-year", with: "2016"

    fill_in "js-password", with: "sekret"

    click_button "I'm in"
    page.should have_content("Awesome, you're in.")

    user = User.last
    user.email.should == "sancho@panza.com"
    user.name.should == "Sancho Panza"
    user.phone_number.should == "19173706969"
    user.card_uri.should_not be_blank
    user.authenticate("sekret").should == user
    plan.reload.users.should include user
  end

  it "Joins the plan as an existing user" do
    plan = FactoryGirl.create(:plan)
    user = FactoryGirl.create(:buyer_user, password: "sekret")
    visit "/#{plan.token}"

    page.should have_content(plan.title)

    click_link "I have a password and want to sign in"

    fill_in "email", with: user.email
    fill_in "password", with: "sekret"

    click_button "I'm in"
    page.should have_content("Awesome, you're in.")
    plan.reload.users.should include user
  end

  it "Joins the plan as an existing user without a credit card" do
    plan = FactoryGirl.create(:plan)
    user = FactoryGirl.create(:user, password: "sekret")

    visit "/#{plan.token}"

    page.should have_content(plan.title)

    click_link "I have a password and want to sign in"

    fill_in "email", with: user.email
    fill_in "password", with: "sekret"

    click_button "I'm in"
    page.should have_content("Looks like we don't have a credit card saved for you.")

    fill_in "js-card-number", with: "4012888888881881"
    fill_in "js-expiration-month", with: "01"
    fill_in "js-expiration-year", with: "2016"

    page.should have_content("Awesome, you're in.")
    user.reload.card_uri.should_not be_blank
    plan.reload.users.should include user
  end
end
