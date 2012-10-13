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

  validate :us_phone_number, if: :phone_number?

  before_create :generate_token, :register_with_balanced_payments

  def as_json(*)
    {
      token: token
    }
  end

  def to_json(*)
    Yajl::Encoder.encode(as_json)
  end

  def phone_number=(phone_number)
    return unless phone_number.present?
    phone_number.gsub!(/[^\d]/,'')
    phone_number = "1#{phone_number}" if phone_number.length == 10
    super(phone_number)
  end

  private

  def us_phone_number
    unless phone_number.length == 11 && phone_number[0] == "1"
      @errors[:phone_number] << "must be in the U.S."
    end
  end

  def generate_token
    self.token = String.random_alphanumeric(40)
  end


  def register_with_balanced_payments
    bank_account = Balanced::BankAccount.new({
      account_number: bank_account_number,
      bank_code: bank_routing_number,
      name: name
    })
    bank_account.save

    merchant = Balanced::Marketplace.my_marketplace.create_merchant(
      email,
      {
        type: "person",
        name: name,
        phone_number: "+#{phone_number}"
      },
      bank_account.uri
    )
    self.balanced_payments_id = merchant.id
  end
end
