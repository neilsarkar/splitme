class PriceBreakdown
  attr_reader :result

  def initialize(plan)
    @plan = plan
    @result = calculate
  end

  private

  def current
    @current ||= @plan.participants_count
  end

  def calculate
    if @plan.fixed_price?
      ((current+1)..(current+5)).to_a.inject([]) do |result, people|
        line = {
          people: people,
          price_per_person: price_string(people)
        }
        line[:current] = true if people == current + 1
        line[:next] = true if people == current + 2
        result.push(line)
      end
    else
      [
        {
          people: "Any number",
          price_per_person: @plan.price_per_person_with_fees_string,
          current: true
        }
      ]
    end
  end

  def price_string(people)
    price_in_cents = (@plan.total_price.to_f / people).floor
    price_in_cents += price_in_cents * 0.03
    price_in_cents += 100.0
    "$%.2f" % (price_in_cents.to_f / 100)
  end
end
