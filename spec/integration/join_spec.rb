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

    page.should have_content(commitment.participant.name)
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

  it "Joins the plan as an existing user" do
    plan = FactoryGirl.create(:plan)
    participant = FactoryGirl.create(:participant, password: "sekret")
    visit "/#{plan.token}"

    page.should have_content(plan.title)

    click_link "I have a password and want to sign in"

    fill_in "email", with: participant.email
    fill_in "password", with: "sekret"

    click_button "I'm in"
    page.should have_content("Awesome, you're in.")
    plan.reload.participants.should include participant
  end
end
