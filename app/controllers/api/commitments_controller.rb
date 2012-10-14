class Api::CommitmentsController < Api::BaseController
  def charge
    commitment = Commitment.find_by_plan_id_and_participant_id!(params[:plan_id], params[:participant_id])
    raise UnauthorizedError unless commitment.plan.user == current_user

    return render_response(commitment, code: 409) unless commitment.unpaid?

    if commitment.charge!
      render_response(commitment, code: 201)
    else
      render_error(400, commitment.errors)
    end
  end
end
