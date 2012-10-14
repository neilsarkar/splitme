class Participant < ActiveRecord::Base
  attr_accessible :card_type, :card_uri, :email, :name, :phone_number

  validates_presence_of :email, :name, :phone_number, :card_uri

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
