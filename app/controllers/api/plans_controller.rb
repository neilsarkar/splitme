class Api::PlansController < Api::BaseController
  def create
    plan = Plan.new(params[:plan])
    plan.user = current_user
    if plan.save
      render_response(plan, status: 201)
    else
      render_error(400, plan.errors)
    end
  end
end
