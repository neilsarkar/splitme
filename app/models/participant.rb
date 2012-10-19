class Participant < ActiveRecord::Base
  attr_accessible :card_type, :card_uri, :email, :name, :phone_number, :password

  validates_presence_of :email, :name, :phone_number, :card_uri, :password

  before_create :create_balanced_buyer

  has_many :commitments
  has_many :plans, through: :commitments

  has_secure_password

  def as_json(options = {})
    if options == :public
      {
        name: name
      }
    else
      {
        id: id,
        email: email,
        name: name,
        phone_number: phone_number,
        card_type: card_type
      }
    end
  end

  private

  def create_balanced_buyer
    balanced_buyer = Balanced::Marketplace.my_marketplace.create_buyer(email, card_uri)
    self.buyer_uri = balanced_buyer.uri
  rescue Exception => e
    raise e unless e.respond_to?(:message)
    @errors[:registration] << e.message
    false
  end
end
