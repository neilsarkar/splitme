class Api::PlansController < Api::BaseController
  skip_before_filter :require_user, only: [:preview, :join]

  def create
    plan = Plan.new(params[:plan])
    plan.user = current_user
    if plan.save
      render_response(plan, code: 201)
    else
      render_error(400, plan.errors)
    end
  end

  def index
    plans = current_user.plans.order("created_at desc")
    render_response(plans)
  end

  def show
    plan = current_user.plans.find(params[:id])
    json = plan.as_json
    json[:participants] = [
      Participant.new(name: "Neil Sarkar", email: "neil@groupme.com", phone_number: "9173706969", card_type: "Visa"),
      Participant.new(name: "Cam Hunt", email: "cam@groupme.com", phone_number: "5035506472", card_type: "Visa"),
      Participant.new(name: "Pat Nakajima", email: "pat@groupme.com", phone_number: "2121231234", card_type: "MasterCard"),
      Participant.new(name: "Joey Pfeifer", email: "joey@groupme.com", phone_number: "2121231235", card_type: "Discover"),
      Participant.new(name: "Kevin David Crowe", email: "kevindavidcrowe@gmail.com", phone_number: "2121231255", card_type: "American Express")
    ]
    json[:breakdown] = {
      "1" => "$100.00",
      "2" => "$50.00",
      "3" => "$33.34",
      "4" => "$25.00",
      "5" => "$20.00"
    }
    render_response(json)
  end

  def collect
    plan = current_user.plans.find(params[:id])
    if plan.collect!
      head :ok
    else
      head 400
    end
  end

  def preview
    plan = Plan.includes(:user).find_by_token!(params[:plan_token])
    render_response(plan.as_json(participants: true, treasurer_name: true))
  end
end
