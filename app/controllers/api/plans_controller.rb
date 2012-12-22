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
    json = plans.map { |plan| plan.as_json(preview: true)}
    render_response(json)
  end

  def show
    plan = current_user.plans.find(params[:id])
    render_response(plan)
  end

  def preview
    plan = Plan.includes(:user).find_by_token!(params[:id])
    render_response(plan.as_json(hide_details: true))
  end

  def collect
    plan = current_user.plans.find(params[:id])
    if plan.collected?
      render_error(409)
    else
      plan.collect!
      broadcaster = Broadcaster.new(plan)
      broadcaster.notify_plan_collected
      render_response(plan)
    end
  end
end
