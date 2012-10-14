class SM.PlanView extends SM.BaseView
  initialize: (token) ->
    @plan = new SM.Plan(token: token)
    @plan.fetch_from_token(
      success: =>
        @render()
      error: =>
        @$el.html("<h1>Sorry, there's no plan at this URL. Please ask your friend for an updated one.</h1>")
    )

  template: """
<h1>{{title}}</h1>
"""

  toJSON: =>
    @plan?.toJSON()
