class Plan < ActiveRecord::Base
  belongs_to :user
  attr_accessible :description, :price_per_person, :title, :total_price, :user_id

  validates_presence_of :title

  validate :price_given

  private

  def price_given
    if total_price.blank? && price_per_person.blank?
      @errors[:price] << "You must provide either a total price or a per person price"
    end
  end
end
