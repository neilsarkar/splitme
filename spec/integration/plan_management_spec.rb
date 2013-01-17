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

    page.should have_content("Welcome, #{user.name}")
    page.should have_content("Team Lunch")
    page.should have_content("Rye House at noon")
    page.should have_content("$100.00")
  end
end
