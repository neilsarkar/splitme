# there must be a better way....

module Balanced
  class BankAccount
    def initialize(*)

    end

    def uri
      "http://balancedpayments.com/uri"
    end

    def save
      true
    end
  end

  class Marketplace
    def initialize(*)
    end

    def self.my_marketplace
      FakeMarketplace.new
    end
  end


  class FakeMarketplace
    def create_merchant(*)
      FakeMerchant.new
    end
  end

  class FakeMerchant
    def id
      "balanced_id_123"
    end
  end
end
