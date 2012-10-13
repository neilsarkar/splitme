class Participant < ActiveRecord::Base
  attr_accessible :balanced_payments_id, :card_type, :email, :name, :phone_number

  validates_presence_of :email, :name, :phone_number
end
