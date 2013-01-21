class SM.PlansView extends SM.BaseView
  initialize: (@user) ->
    @on "render", @fetchPlans

  toJSON: =>
    name: @user.name
    has_bank_account: @user.has_bank_account

  fetchPlans: =>
    SM.Plan.all().done(@addPlans).fail(@notify)

  addPlans: (response) =>
    @plans = response.response
    for plan in @plans
      html = Mustache.to_html(@planTemplate, plan)
      @$el.append(html)

  notify: ->
    @$el.append("Sorry, we couldn't fetch your plans. Please reload the page.")

  create: ->
    window.app.navigate("plans/new", triggerRoute=true)

  linkBankAccount: ->
    window.app.navigate("payment_information", triggerRoute=true)

  events: {
    "click .create": "create"
    "click .bank-account": "linkBankAccount"
  }

  template: """
  <h1>Welcome, {{name}}</h1>
  <a href='javascript:void(0)' class='create'>+</a>
  {{^has_bank_account}}
  <div class="bank-account-reminder">
    <p>
      Looks like you don't have a bank account linked.
    </p>
    <p>
      You can still create plans and have your friends join,
      but you'll need to connect a bank account before you can
      collect the money.
    </p>
    <p>
      <a href='javascript:void(0)' class='bank-account'>Link Bank Account</a>
    </p>
  </div>
  {{/has_bank_account}}
"""

  planTemplate: """
  <div class='plan'>
    <div class='title'>{{title}}</div>
    <div class='description'>{{description}}</div>
    <div class='price'>{{total_price}}</div>
  </div>
"""
