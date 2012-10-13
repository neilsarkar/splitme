class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :bank_account_number,
                  :bank_routing_number,
                  :email,
                  :name,
                  :phone_number,
                  :token,
                  :password

  validates_presence_of :bank_account_number,
                        :bank_routing_number,
                        :email,
                        :name,
                        :phone_number,
                        :password

  before_create :generate_token

  def generate_token
    self.token = String.random_alphanumeric(40)
  end

  def as_json(*)
    {
      token: token
    }
  end

  def to_json(*)
    Yajl::Encoder.encode(as_json)
  end
end
