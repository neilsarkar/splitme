class Commitment < ActiveRecord::Base
  attr_accessible :participant_id, :plan_id

  validates_presence_of :participant_id, :plan_id
  validates_uniqueness_of :participant_id, :scope => :plan_id

  belongs_to :participant
  belongs_to :plan
end
