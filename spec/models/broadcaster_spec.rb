require "spec_helper"

describe Broadcaster do
  include EmailSpec::Matchers

  before do
    user = FactoryGirl.create(:user, email: "neil.r.sarkar@gmail.com")
    @plan = FactoryGirl.create(:plan, user: user)
    @broadcaster = Broadcaster.new(@plan)
  end

  it "#notify_plan_joined" do
    commitment = FactoryGirl.create(:commitment, plan: @plan)
    @plan.reload
    @broadcaster.notify_plan_joined(commitment.user)

    Pony.deliveries.should_not be_blank
    email = Pony.deliveries.last
    email.should be_delivered_to @plan.user.email
    email.should cc_to commitment.user.email
    email.should have_subject @plan.title

    email.should have_body_text "#{commitment.user.name} is in."
    email.should have_body_text @plan.total_price_string
    email.should have_body_text @plan.price_per_person_string
  end
end
