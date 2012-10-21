class Api::CommitmentsController < Api::BaseController
  skip_before_filter :require_user, only: [:create]

  def create
    participant = Participant.find_by_email!(params[:participant][:email])
    participant = participant.authenticate(params[:participant][:password])
    return head 401 if participant.blank?
    plan = Plan.find_by_token(params[:plan_token])

    if plan.participants.include?(participant)
      head 409
    else
      commitment = Commitment.create(plan_id: plan.id, participant_id: participant.id)
      broadcaster = Broadcaster.new(plan)
      broadcaster.notify_plan_joined(participant)
      render_response(participant, code: 201)
    end
  end

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
