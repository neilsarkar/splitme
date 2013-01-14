class Api::CommitmentsController < Api::BaseController
  def create
    plan = Plan.find_by_token!(params[:plan_token])

    if current_user.card_uri.blank?
      render_error(400, ["User does not have a credit card in the system."])
    elsif plan.users.include?(current_user)
      head 409
    else
      commitment = Commitment.create(plan_id: plan.id, user_id: current_user.id)
      broadcaster = Broadcaster.new(plan)
      broadcaster.notify_plan_joined(current_user)
      render_response(current_user, code: 201)
    end
  end

  def charge
    commitment = Commitment.find_by_plan_id_and_user_id!(params[:plan_id], params[:user_id])
    raise UnauthorizedError unless commitment.plan.user == current_user

    return render_response(commitment, code: 409) unless commitment.unpaid? || commitment.failed?

    if commitment.charge!
      render_response(commitment, code: 201)
    else
      render_error(400, commitment.errors)
    end
  end
end
