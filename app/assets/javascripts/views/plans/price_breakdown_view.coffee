class SM.PriceBreakdownView extends SM.BaseView
  initialize: (@plan) ->
    @plan.on "change", @recalculate
    @recalculate()

  template: """
Total: {{total_price}}
<table>
  <tr>
    <th>People</th>
    <th>Cost per Person</th>
  </tr>
  {{#breakdown}}
    <tr class={{class_name}}>
      <td>{{number}}</td>
      <td>{{price}}</td>
    </tr>
  {{/breakdown}}
</table>
"""

  recalculate: =>
    return unless @plan.participants && @plan.get("fixed_price")

    @count = @plan.participants.length + 2
    @total = parseInt(parseFloat(@plan.get("total_price").replace(/[^\d.]/g, ''))*100)

    @breakdown = []
    for num in [Math.max(1, @count - 2)..Math.max(5, @count + 2)]
      @breakdown.push({
        number: num
        price: @price(num)
        class_name: "current" if num == @count
      })

  price: (number) =>
    integer = Math.ceil(@total / number)
    "$#{(parseFloat(integer) / 100).toFixed(2)}"

  toJSON: =>
    breakdown: @breakdown
    total_price: @plan.get("total_price")
