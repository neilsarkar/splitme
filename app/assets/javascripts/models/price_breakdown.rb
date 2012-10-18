class PriceBreakdown
  attr_reader :breakdown

  def initialize(plan)
    @plan = plan
    @breakdown = calculate
  end

  private

  def count
    @count ||= @plan.participants.size.to_i + 2
  end

  def calculate
    return [] unless @plan.fixed_price?

    start = [1, count-2].max
    finish = [5,count+2].max

    (start..finish).to_a.inject([]) do |result, people|
      line = {
        people: people,
        price_per_person: price_string(people)
      }
      line[:current] = true if people == count - 1
      line[:next] = true if people == count
      result.push(line)
    end
  end

  def price_string(people)
    price_in_cents = (@plan.total_price.to_f / people).ceil
    "$%.2f" % (price_in_cents.to_f / 100)
  end
end
