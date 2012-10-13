class Api::PlansController < Api::BaseController
  def index
    plans = current_user.plans.order("created_at desc")
    render_response(plans)
  end

  def create
    plan = Plan.new(params[:plan])
    plan.user = current_user
    if plan.save
      render_response(plan, code: 201)
    else
      render_error(400, plan.errors)
    end
  end
end
