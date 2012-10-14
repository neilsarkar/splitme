require "spec_helper"

describe "Viewing Plan" do
  it "Shows plan details" do
    plan = FactoryGirl.create(:plan, total_price: 10000)
    commitment_1 = FactoryGirl.create(:commitment, plan: plan)
    commitment_2 = FactoryGirl.create(:commitment, plan: plan)
    visit "/#{plan.token}"

    page.should have_content(plan.title)
    page.should have_content(plan.description)

    page.should have_content(plan.user.name)
    page.should have_content("1")
    page.should have_content("$100.00")
    page.should have_content("2")
    page.should have_content("$50.00")
    page.should have_content("3")
    page.should have_content("$33.34")
    page.should have_content("4")
    page.should have_content("$25.00")
    page.should have_content("5")
    page.should have_content("$20.00")
    page.find(".current").should have_content "$25.00"

    page.should have_content(commitment_1.participant.name)
    page.should have_content(commitment_2.participant.name)
  end
end
