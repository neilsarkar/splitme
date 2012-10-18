require "spec_helper"

describe PriceBreakdown do
  describe "#result" do
    context "when no-one has bought in" do
      it "shows the first 5 prices" do
        plan = stub(total_price: 10000, participants: [], fixed_price?: true)
        price_breakdown = PriceBreakdown.new(plan)

        result = price_breakdown.result
        result.size.should == 5
        result[0].should == {
          people: 1,
          price_per_person: "$100.00",
          current: true
        }
        result[1].should == {
          people: 2,
          price_per_person: "$50.00",
          next: true
        }
        result[2].should == {
          people: 3,
          price_per_person: "$33.34"
        }
        result[3].should == {
          people: 4,
          price_per_person: "$25.00"
        }
        result[4].should == {
          people: 5,
          price_per_person: "$20.00"
        }
      end
    end

    context "when more than 2 people have bought in" do
      it "shows 5 prices, starting at 1 before the current" do
        plan = stub(total_price: 10000, participants: [1,2,3], fixed_price?: true)
        price_breakdown = PriceBreakdown.new(plan)

        result = price_breakdown.result
        result.size.should == 5
        result[0].should == {
          people: 4,
          price_per_person: "$25.00",
          current: true
        }
        result[1].should == {
          people: 5,
          price_per_person: "$20.00",
          next: true
        }
        result[2].should == {
          people: 6,
          price_per_person: "$16.67"
        }
        result[3].should == {
          people: 7,
          price_per_person: "$14.29"
        }
        result[4].should == {
          people: 8,
          price_per_person: "$12.50"
        }
      end
    end

    context "when plan price is per person" do
      it "returns an empty array" do
        plan = stub(total_price: 10000, participants: [], fixed_price?: false)
        price_breakdown = PriceBreakdown.new(plan)
        price_breakdown.result.should == []
      end
    end
  end
end
