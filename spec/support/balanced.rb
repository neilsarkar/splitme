# there must be a better way....

module Balanced
  class BankAccount
    def initialize(*)

    end

    def uri
      "http://balancedpayments.com/card_uri"
    end

    def save
      self
    end
  end

  class Marketplace
    def initialize(*)
    end

    def self.my_marketplace
      FakeMarketplace.new
    end
  end

  class Account
    def self.find_by_email(email)
      FakeAccount.new
    end
  end

  class FakeAccount
    def debit(amount, name)
      FakeDebit.new
    end

    def credit(amount)
      FakeCredit.new
    end
  end

  class FakeDebit
    def uri
      "/debit/sskdcnskdjcnbb"
    end
  end

  class FakeCredit
    def uri
      "/credit/sjdkncsoiqeior"
    end
  end

  class FakeMarketplace
    def create_merchant(*)
      FakeMerchant.new
    end

    def create_buyer(*)
      FakeBuyer.new
    end
  end

  class FakeMerchant
    def id
      "balanced_id_123"
    end
  end

  class FakeBuyer
    def uri
      "https://balancedpayments.com/buyer_uri"
    end
  end
end
