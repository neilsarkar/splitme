require "spec_helper"

describe PriceBreakdown do
  describe "#result" do
    context "when no-one has bought in" do
      it "shows the first 5 prices, starting at current" do
        plan = stub(total_price: 10000, participants_count: 1, fixed_price?: true)
        price_breakdown = PriceBreakdown.new(plan)

        result = price_breakdown.result
        result.size.should == 5
        result[0].should == {
          people: 2,
          price_per_person: "$52.50", # $50.00 + fees
          current: true
        }
        result[1].should == {
          people: 3,
          price_per_person: "$35.33", # $33.33 + fees
          next: true
        }
        result[2].should == {
          people: 4,
          price_per_person: "$26.75" # $25.00 + fees
        }
        result[3].should == {
          people: 5,
          price_per_person: "$21.60" # $20.00 + fees
        }
        result[4].should == {
          people: 6,
          price_per_person: "$18.16" # $16.66 + fees
        }
      end
    end

    context "when more than 2 people have bought in" do
      it "shows 5 prices, starting one after the current" do
        plan = stub(total_price: 10000, participants_count: 4, fixed_price?: true)
        price_breakdown = PriceBreakdown.new(plan)

        result = price_breakdown.result
        result.size.should == 5
        result[0].should == {
          people: 5,
          price_per_person: "$21.60",
          current: true
        }
        result[1].should == {
          people: 6,
          price_per_person: "$18.16",
          next: true
        }
        result[2].should == {
          people: 7,
          price_per_person: "$15.71"
        }
        result[3].should == {
          people: 8,
          price_per_person: "$13.88"
        }
        result[4].should == {
          people: 9,
          price_per_person: "$12.44"
        }
      end
    end

    context "when plan price is per person" do
      it "returns one line" do
        plan = stub(price_per_person_with_fees_string: "$11.30", participants_count: 1, fixed_price?: false)
        price_breakdown = PriceBreakdown.new(plan)
        price_breakdown.result.should == [
          {
            people: "Any number",
            price_per_person: "$11.30",
            current: true
          }
        ]
      end
    end
  end
end
