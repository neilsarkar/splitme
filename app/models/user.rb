class User < ActiveRecord::Base
  has_many :plans

  has_secure_password

  attr_accessor :bank_account_number, :bank_routing_number

  attr_accessible :bank_account_number,
                  :bank_routing_number,
                  :email,
                  :name,
                  :phone_number,
                  :password,
                  :date_of_birth,
                  :street_address,
                  :zip_code,
                  :card_uri,
                  :card_type

  validates_presence_of :email,
                        :name,
                        :phone_number

  validates_presence_of :password, on: :create

  validates_uniqueness_of :email, case_sensitive: false
  validate :valid_email_format, if: :email?

  validate :us_phone_number, if: :phone_number?
  validate :valid_date_of_birth, if: :date_of_birth?

  before_save :add_bank_account, if: :bank_account_number
  before_save :add_card, if: :card_uri_changed?
  before_create :generate_token

  def as_json(*)
    {
      token: token,
      has_bank_account: bank_account_uri.present?,
      has_card: card_uri.present?
    }
  end

  def phone_number=(phone_number)
    return unless phone_number.present?
    phone_number.gsub!(/[^\d]/,'')
    phone_number = "1#{phone_number}" if phone_number.length == 10
    super(phone_number)
  end

  def balanced_account
    @balanced_account ||= Balanced::Account.find_by_email(email)
  end

  def email=(new_email)
    super(new_email.try(:downcase).try(:strip))
  end

  def self.find_by_email(email)
    super(email.try(:downcase))
  end

  def self.find_by_email!(email)
    super(email.try(:downcase))
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

  def add_card
    if balanced_account_uri.blank?
      buyer = Balanced::Marketplace.mine.create_buyer({
        email_address: email,
        card_uri: card_uri,
        name: name
      })
      self.balanced_account_uri = buyer.uri
    elsif !card_uri_exists?
      balanced_account.add_card(card_uri)
    else
      true
    end
  end

  def card_uri_exists?
    balanced_account.cards.map(&:id).include?(card_uri.split("/").last)
  end

  def add_bank_account
    bank_account = Balanced::Marketplace.mine.create_bank_account({
      account_number: bank_account_number,
      bank_code: bank_routing_number,
      name: name
    })

    if balanced_account_uri.present?
      unless bank_account_uri.present?
        balanced_account.promote_to_merchant({
          type: "person",
          name: name,
          phone_number: "+#{phone_number}",
          street_address: street_address,
          postal_code: zip_code,
          dob: balanced_dob
        })
      end
      balanced_account.add_bank_account(bank_account.uri)
    else
      merchant = Balanced::Marketplace.mine.create_merchant(
        email_address: email,
        merchant: {
          type: "person",
          name: name,
          phone_number: "+#{phone_number}",
          street_address: street_address,
          postal_code: zip_code,
          dob: balanced_dob
        },
        bank_account_uri: bank_account.uri,
        name: name
      )
      self.balanced_account_uri = merchant.uri
    end

    self.bank_account_uri = bank_account.uri
  rescue Balanced::Conflict => e
    @errors[:email] << "already registered"
    false
  rescue Exception => e
    if e.respond_to?(:body)
      @errors[:bank_account] << e.body["description"]
    else
      @errors[:bank_account] << e.message
    end
    Airbrake.notify(e)
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
