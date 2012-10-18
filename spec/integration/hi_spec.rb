require "spec_helper"

describe "Hi" do
  it "should say hi" do
    visit "/"
    page.should have_content("don't sue us.")
  end
end
