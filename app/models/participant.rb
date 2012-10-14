class Participant < ActiveRecord::Base
  attr_accessible :card_type, :card_uri, :email, :name, :phone_number

  validates_presence_of :email, :name, :phone_number, :card_uri

  before_create :create_balanced_buyer

  def as_json(*)
    {
      id: id,
      email: email,
      name: name,
      phone_number: phone_number,
      card_type: card_type
    }
  end

  private

  def create_balanced_buyer
    balanced_buyer = Balanced::Marketplace.my_marketplace.create_buyer(email, card_uri)
    self.buyer_uri = balanced_buyer.uri
  rescue
    @errors[:registration] << "Something went wrong in creating your buyer account"
    false
  end
end
