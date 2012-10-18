require "spec_helper"

describe PriceBreakdown do
  describe "#breakdown" do
    context "when no-one has bought in" do
      it "shows the first 5 prices" do
        plan = stub(total_price: 10000, participants: [], fixed_price?: true)
        price_breakdown = PriceBreakdown.new(plan)

        breakdown = price_breakdown.breakdown
        breakdown.size.should == 5
        breakdown[0].should == {
          people: 1,
          price_per_person: "$100.00",
          current: true
        }
        breakdown[1].should == {
          people: 2,
          price_per_person: "$50.00",
          next: true
        }
        breakdown[2].should == {
          people: 3,
          price_per_person: "$33.34"
        }
        breakdown[3].should == {
          people: 4,
          price_per_person: "$25.00"
        }
        breakdown[4].should == {
          people: 5,
          price_per_person: "$20.00"
        }
      end
    end

    context "when more than 2 people have bought in" do
      it "shows 5 prices, starting at 1 before the current" do
        plan = stub(total_price: 10000, participants: [1,2,3], fixed_price?: true)
        price_breakdown = PriceBreakdown.new(plan)

        breakdown = price_breakdown.breakdown
        breakdown.size.should == 5
        breakdown[0].should == {
          people: 3,
          price_per_person: "$33.34",
        }
        breakdown[1].should == {
          people: 4,
          price_per_person: "$25.00",
          current: true
        }
        breakdown[2].should == {
          people: 5,
          price_per_person: "$20.00",
          next: true
        }
        breakdown[3].should == {
          people: 6,
          price_per_person: "$16.67"
        }
        breakdown[4].should == {
          people: 7,
          price_per_person: "$14.29"
        }
      end
    end

    context "when plan price is per person" do
      it "returns an empty array" do
        plan = stub(total_price: 10000, participants: [], fixed_price?: false)
        price_breakdown = PriceBreakdown.new(plan)
        price_breakdown.breakdown.should == []
      end
    end
  end
end
