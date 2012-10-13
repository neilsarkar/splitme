class Participant < ActiveRecord::Base
  attr_accessible :balanced_payments_id, :card_type, :email, :name, :phone_number

  validates_presence_of :email, :name, :phone_number

  def as_json(*)
    {
      id: id,
      email: email,
      name: name,
      phone_number: phone_number,
      card_type: card_type
    }
  end
end
