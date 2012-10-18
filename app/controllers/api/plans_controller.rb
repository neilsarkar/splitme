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
    json = plan.as_json(participants: true, breakdown: true)
    render_response(json)
  end

  def preview
    plan = Plan.includes(:user).find_by_token!(params[:plan_token])
    render_response(plan.as_json(participants: true, treasurer_name: true, breakdown: true))
  end

  def collect
    plan = current_user.plans.find(params[:id])
    if plan.collected?
      render_error(409)
    else
      plan.collect!
      render_response(plan)
    end
  end
end
