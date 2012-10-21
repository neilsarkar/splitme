class Api::ParticipantsController < Api::BaseController
  skip_before_filter :require_user, only: [:create]

  def create
    plan = Plan.find_by_token!(params[:plan_token])
    participant = Participant.new(params[:participant])
    if participant.save
      Commitment.create(plan: plan, participant: participant)
      broadcaster = Broadcaster.new(plan)
      broadcaster.notify_plan_joined(participant)
      render_response(participant, code: 201)
    else
      render_error(400, participant.errors)
    end
  end
end
