require "spec_helper"

describe "Plan Management" do
  it "shows your existing plans" do
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
end
