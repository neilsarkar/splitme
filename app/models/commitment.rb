class Commitment < ActiveRecord::Base
  attr_accessible :participant_id, :plan_id, :participant, :plan

  validates_presence_of :participant_id, :plan_id
  validates_uniqueness_of :participant_id, :scope => :plan_id

  belongs_to :participant
  belongs_to :plan

  before_create :set_state

  def collect!

  end

  def unpaid?
    state == "unpaid"
  end

  def failed?
    state == "failed"
  end

  def paid?
    state == "paid"
  end

  private

  def set_state
    self.state = "unpaid"
  end
end
