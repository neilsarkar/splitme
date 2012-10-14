class Api::CommitmentsController < Api::BaseController
  def collect
    commitment = Commitment.find_by_plan_id_and_participant_id!(params[:plan_id], params[:participant_id])
    return render_error(409) unless commitment.unpaid?

    if commitment.collect!
      render_response(commitment, code: 201)
    else
      render_error(400, commitment.errors)
    end
  end
end
