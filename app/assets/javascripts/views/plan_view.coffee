class SM.PlanView extends SM.BaseView
  mappings: {
    "price_breakdown": "#price-breakdown"
    "participants": "#participants"
  }

  initialize: (token) ->
    @plan = new SM.Plan(token: token)
    @views.price_breakdown = new SM.PriceBreakdownView(@plan)
    @views.participants = new SM.ParticipantsView(@plan)

    @plan.fetch_from_token(
      success: @render
      error: =>
        @$el.html("<h1>Sorry, there's no plan at this URL. Please ask your friend for an updated one.</h1>")
    )

  template: """
<h1>{{title}}</h1>
<h2>{{description}}</h2>
<div id='price-breakdown'></div>
<div id='participants'></div>
"""

  toJSON: =>
    @plan?.toJSON()
