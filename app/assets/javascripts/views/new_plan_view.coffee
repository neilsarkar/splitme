class SM.NewPlanView extends SM.FormView
  process: =>
    @$el.disableForm()

    planAttributes = {
      title: @value("title")
      description: @value("description")
    }

    price_format = @$el.find("input[name=price_format]:checked").val()
    planAttributes[price_format] = @value("amount")

    SM.Plan.create(planAttributes).done(@redirect).error(@error)

  redirect: =>
    window.app.navigate("plans", triggerRoute=true)

  template: """
<h1> New Plan </h1>
<div class="plan-info">
  <input id="js-title" placeholder="Title"/>
  <textarea id="js-description" placeholder="Description"></textarea>
</div>

<div class="payment-info">
  <input id="js-amount" type="tel" placeholder="$ in USD" />
  <input type="radio" id="js-total-price" name="price_format" value="total_price" checked="checked"/>
  <label for="js-total-price">Total Price</label>
  <input type="radio" id="js-price-per-person" name="price_format" value="price_per_person" />
</div>

<input type="submit" value="Start" class="btn btn-success" />
"""
