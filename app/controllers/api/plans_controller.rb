class Api::PlansController < Api::BaseController
  skip_before_filter :require_user, only: [:preview]

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
    render_response(plan.as_json(participants: true))
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
    plan = Plan.find_by_token!(params[:plan_token])
    render_response(plan.as_json(participants: true))
  end
end
