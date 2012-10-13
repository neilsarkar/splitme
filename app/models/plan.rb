class Plan < ActiveRecord::Base
  belongs_to :user
  attr_accessible :description, :price_per_person, :title, :total_price, :user_id

  validates_presence_of :title

  validate :price_exclusive_or

  before_create :set_token

  def as_json(options = {})
    json = {
      id: id,
      token: token,
      title: title,
      description: description,
      total_price: total_price_string,
      price_per_person: price_per_person_string
    }
    json[:participants] = participants.as_json if options[:participants].present?
    json
  end

  def total_price_string
    price_string(total_price)
  end

  def price_per_person_string
    price_string(price_per_person)
  end

  def total_price
    @total_price ||= (super || price_per_person * participants_count)
  end

  def price_per_person
    @price_per_person ||= (super || total_price / participants_count)
  end

  def total_price=(price)
    super(parse_price(price))
  end

  def price_per_person=(price)
    super(parse_price(price))
  end

  def collect!
    true
  end

  def participants
    @participants ||= [
      Participant.new(name: "Neil Sarkar", email: "neil@groupme.com", phone_number: "9173706969", card_type: "Visa"),
      Participant.new(name: "Cam Hunt", email: "cam@groupme.com", phone_number: "5035506472", card_type: "Visa"),
      Participant.new(name: "Pat Nakajima", email: "pat@groupme.com", phone_number: "2121231234", card_type: "MasterCard"),
      Participant.new(name: "Joey Pfeifer", email: "joey@groupme.com", phone_number: "2121231235", card_type: "Discover"),
      Participant.new(name: "Kevin David Crowe", email: "kevindavidcrowe@gmail.com", phone_number: "2121231255", card_type: "American Express")
    ]
  end

  private

  def participants_count
    participants.blank? ? 1 : participants.length + 1
  end

  def set_token
    self.token = String.random_alphanumeric(20)
  end

  def price_string(price)
    "$%.2f" % (price.to_f / 100)
  end

  def parse_price(price)
    return nil if price.blank?
    return price if price.is_a? Integer
    (price.to_s.gsub(/[^\d.]/,'').to_f * 100).to_i
  end

  def price_exclusive_or
    if read_attribute(:total_price).blank? && read_attribute(:price_per_person).blank?
      @errors[:price] << "You must provide either a total price or a per person price"
    elsif read_attribute(:total_price).present? && read_attribute(:price_per_person).present?
      @errors[:price] << "You cannot specify both a total price and a per person price"
    end
  end
end
