class Plan < ActiveRecord::Base
  belongs_to :user
  attr_accessible :description, :price_per_person, :title, :total_price, :user_id

  validates_presence_of :title

  validate :price_exclusive_or

  before_create :set_token

  has_many :commitments
  has_many :participants, through: :commitments

  def as_json(options = {})
    json = {
      id: id,
      token: token,
      title: title,
      description: description,
      total_price: total_price_string,
      price_per_person: price_per_person_string,
      is_fixed_price: fixed_price?,
      is_locked: locked?,
      is_collected: collected?
    }

    unless json[:preview].present?
      json[:participants] = participants_json(options[:hide_details])
      json[:treasurer_name] = user.name
      json[:breakdown] = PriceBreakdown.new(self).result
    end

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

  def price_per_person_with_fees
    price_per_person + 100 + (price_per_person*0.03).round
  end

  def total_price=(price)
    super(parse_price(price))
  end

  def price_per_person=(price)
    super(parse_price(price))
  end

  def total_escrowed
    @total_escrowed ||= commitments.escrowed.size * price_per_person
  end

  def collected?
    return false unless locked?
    commitments.present? and commitments.collected.size + commitments.failed.size == commitments.size
  end

  def collect!
    return unless total_escrowed > 0
    merchant = Balanced::Account.find_by_email(user.email)
    if credit = merchant.credit(total_escrowed)
      update_attribute :credit_uri, credit.uri
      commitments.escrowed.each &:mark_collected!
    end
  end

  def lock!
    update_attribute :locked, true unless locked?
  end

  def fixed_price?
    read_attribute(:total_price).present?
  end

  private

  def participants_count
    participants.blank? ? 1 : participants.length + 1
  end

  def participants_json(hide_details)
    if hide_details
      participants.map { |participant| participant.as_json(:public) }
    else
      commitments.map do |commitment|
        commitment.participant.as_json.merge(state: commitment.state)
      end
    end
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
