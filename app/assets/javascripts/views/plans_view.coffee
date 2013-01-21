class SM.PlansView extends SM.BaseView
  initialize: (@user) ->
    @on "render", @fetchPlans

  toJSON: =>
    name: @user.name

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

  events: {
    "click .create": "create"
  }

  template: """
  <h1>Welcome, {{name}}</h1>
  <a href='javascript:void(0)' class='create'>+</a>
"""

  planTemplate: """
  <div class='plan'>
    <div class='title'>{{title}}</div>
    <div class='description'>{{description}}</div>
    <div class='price'>{{total_price}}</div>
  </div>
"""
