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
    alert("Sorry, we couldn't fetch your plans")

  template: """
  <h1>Welcome, {{name}}</h1>
"""

  planTemplate: """
  <div class='plan'>
    <div class='title'>{{title}}</div>
    <div class='description'>{{description}}</div>
    <div class='price'>{{total_price}}</div>
  </div>
"""
