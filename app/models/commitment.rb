class Commitment < ActiveRecord::Base
  attr_accessible :user_id, :plan_id, :user, :plan

  validates_presence_of :user_id, :plan_id
  validates_uniqueness_of :user_id, :scope => :plan_id

  belongs_to :user
  belongs_to :plan

  before_create :set_state

  scope :escrowed, where(state: "escrowed")
  scope :collected, where(state: "collected")
  scope :failed, where(state: "failed")

  def charge!
    plan.lock!

    buyer = Balanced::Account.find_by_email(user.email)
    if charge = buyer.debit(plan.price_per_person_with_fees, plan.title)
      mark_escrowed!
      update_attribute :debit_uri, charge.uri
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
      name: user.name,
      state: state,
      email: user.email,
      phone_number: user.phone_number,
      id: user.id
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
