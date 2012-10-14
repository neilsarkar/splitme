require "spec_helper"

describe "Viewing Plan" do
  it "Shows plan details" do
    plan = FactoryGirl.create(:plan, total_price: 10000)
    commitment_1 = FactoryGirl.create(:commitment, plan: plan)
    commitment_2 = FactoryGirl.create(:commitment, plan: plan)
    visit "/#{plan.token}"

    page.should have_content(plan.title)
    page.should have_content(plan.description)

    # Real data
    # page.should have_content("1")
    # page.should have_content("$100.00")
    # page.should have_content("2")
    # page.should have_content("$50.00")
    # page.should have_content("3")
    # page.should have_content("$33.33")
    # page.should have_content("4")
    # page.should have_content("$25.00")
    # page.should have_content("5")
    # page.should have_content("$20.00")
    # page.find(".current").should have_content "$33.33"

    # Fake Data
    page.should have_content("$20.00")
    page.should have_content("$16.67")
    page.should have_content("$14.29")
    page.should have_content("$12.50")
    page.should have_content("$11.12")
    page.find(".current").should have_content "$14.29"

    page.should have_content(commitment_1.participant.name)
    page.should have_content(commitment_2.participant.name)
  end
end
