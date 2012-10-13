class Plan < ActiveRecord::Base
  belongs_to :user
  attr_accessible :description, :price_per_person, :title, :total_price, :user_id

  validates_presence_of :title

  validate :price_given

  def as_json(*)
    {
      id: id,
      title: title,
      description: description,
      total_price: total_price_string,
      price_per_person: price_per_person_string
    }
  end

  def total_price_string
    price_string(total_price)
  end

  def price_per_person_string
    price_string(price_per_person)
  end

  def total_price=(price)
    super(parse_price(price))
  end

  def price_per_person=(price)
    super(parse_price(price))
  end

  private

  def price_string(price)
    "$%.2f" % (price.to_f / 100)
  end

  def parse_price(price)
    return nil if price.blank?
    return price if price.is_a? Integer
    (price.to_s.gsub(/[^\d.]/,'').to_f * 100).to_i
  end

  def price_given
    if total_price.blank? && price_per_person.blank?
      @errors[:price] << "You must provide either a total price or a per person price"
    end
  end
end
