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

  def merchant_user_error?
    !plan.user.has_bank_account?
  end

  def charge!
    return false if merchant_user_error?

    plan.lock!

    buyer = Balanced::Account.find_by_email(user.email)
    charge = buyer.debit({
      amount: plan.price_per_person_with_fees,
      appears_on_statement_as: plan.statement_title,
      merchant_uri: plan.user.balanced_account_uri
    })

    if charge
      mark_escrowed!
      update_attribute :debit_uri, charge.uri
      charge.uri
    else
      mark_failed!
      false
    end
  rescue
    mark_failed!
    raise
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
