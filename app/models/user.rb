class User < ActiveRecord::Base
  has_many :plans

  has_secure_password

  attr_accessible :bank_account_number,
                  :bank_routing_number,
                  :email,
                  :name,
                  :phone_number,
                  :password,
                  :date_of_birth,
                  :street_address,
                  :zip_code

  validates_presence_of :bank_account_number,
                        :bank_routing_number,
                        :email,
                        :name,
                        :phone_number,
                        :password,
                        :date_of_birth

  validates_uniqueness_of :email
  validate :valid_email_format, if: :email?

  validate :us_phone_number, if: :phone_number?
  validate :valid_date_of_birth, if: :date_of_birth?

  before_create :generate_token, :register_with_balanced_payments

  def as_json(*)
    {
      token: token
    }
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
    }).save

    merchant = Balanced::Marketplace.my_marketplace.create_merchant(
      email,
      {
        type: "person",
        name: name,
        phone_number: "+#{phone_number}",
        street_address: street_address,
        postal_code: zip_code,
        dob: balanced_dob
      },
      bank_account.uri
    )
    self.balanced_payments_id = merchant.id
  rescue Balanced::Conflict => e
    @errors[:email] << "already registered"
  rescue Exception => e
    if e.respond_to?(:body)
      @errors[:bank_account] << e.body["description"]
    else
      @errors[:bank_account] << e.message
    end
    false
  end

  def valid_date_of_birth
    unless date_of_birth.match /\d+\/\d{4}/
      @errors[:date_of_birth] << "Date of birth must be in format mm/yyyy"
    end
  end

  def valid_email_format
    email_name_regex  = '[A-Z0-9_\.%\+\-\']+'
    domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
    domain_tld_regex  = '(?:[A-Z]{2,4}|museum|travel)'

    unless email.match /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
      @errors[:email] << "must be a valid format"
    end
  end

  def balanced_dob
    month, year = date_of_birth.split("/")
    month = "0#{month}" if month.length == 1
    "#{year}-#{month}"
  end
end
