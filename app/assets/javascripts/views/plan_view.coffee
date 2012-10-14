class SM.PlanView extends SM.BaseView
  mappings: {
    "price_breakdown": "#price-breakdown"
    "participants": "#participants"
    "join": "#join"
  }

  initialize: (token) ->
    @plan = new SM.Plan(token: token)
    @views.price_breakdown = new SM.PriceBreakdownView(@plan)
    @views.participants = new SM.ParticipantsView(@plan)
    @views.join = new SM.JoinView(@plan)

    @plan.fetch_from_token(
      success: @render
      error: =>
        @$el.html("<h1>Sorry, there's no plan at this URL. Please ask your friend for an updated one.</h1>")
    )

  template: """
<h1>{{title}}</h1>
<h2>{{description}}</h2>
<h3> Price Breakdown </h3>
<div id='price-breakdown'></div>
<h3> Who's in </h3>
<div id='participants'></div>
<h3> Join </h3>
<div id='join'></div>
"""

  toJSON: =>
    @plan?.toJSON()
