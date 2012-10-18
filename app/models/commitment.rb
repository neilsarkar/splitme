class Commitment < ActiveRecord::Base
  attr_accessible :participant_id, :plan_id, :participant, :plan

  validates_presence_of :participant_id, :plan_id
  validates_uniqueness_of :participant_id, :scope => :plan_id

  belongs_to :participant
  belongs_to :plan

  before_create :set_state

  scope :escrowed, where(state: "escrowed")
  scope :collected, where(state: "collected")

  def charge!
    plan.update_attribute :locked, true unless plan.locked?

    buyer = Balanced::Account.find_by_email(participant.email)
    if buyer.debit(plan.price_per_person_with_fees, plan.title)
      mark_escrowed!
    else
      mark_failed!
    end
  rescue
    mark_failed!
    false
  end

  def unpaid?
    state == "unpaid"
  end

  def failed?
    state == "failed"
  end

  def escrowed?
    state == "escrowed"
  end

  def collected?
    state == "collected"
  end

  def as_json(*)
    {
      state: state
    }
  end

  def mark_collected!
    update_attribute :state, "collected"
  end

  private

  def mark_failed!
    update_attribute :state, "failed"
  end

  def mark_escrowed!
    update_attribute :state, "escrowed"
  end

  def set_state
    self.state = "unpaid"
  end
end
