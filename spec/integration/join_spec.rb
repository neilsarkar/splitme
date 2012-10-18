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
    page.should have_content("$33.34")
    page.should have_content("4")
    page.should have_content("$25.00")
    page.should have_content("5")
    page.should have_content("$20.00")
    page.should have_content("6")
    page.should have_content("$16.67")

    page.find(".current").should have_content "$50.00"
    page.find(".next").should have_content "$33.34"

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
end
