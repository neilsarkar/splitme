class SM.AdminPlanView extends SM.BaseView
  initialize: (@user, @plan_id) ->

  render: =>
    return super if @plan

    SM.Plan.find(@plan_id).done((response) =>
      @plan = SM.Plan.new(response.response)
      @views.price_breakdown = new SM.PriceBreakdownView(@plan)
      @views.participants = new SM.AdminParticipantsView(@plan, delegate: this)
      @views.collect = new SM.CollectView(@plan, delegate: this)
      super
    )

  chargeCards: =>
    @plan.charge().done =>
      @plan.fetch()

  toJSON: =>
    @plan?.toJSON()

  subviews: {
    "price_breakdown": "#price-breakdown"
    "participants": "#participants"
    "collect": "#collect"
  }

  template: """
<h1> {{title}} </h1>
<p> {{description}} </p>
<p> {{total_price}} </p>
<p> Your link: <a href="/token">/{{token}}</a> </p>
<div id="price-breakdown"></div>
<div id="participants"></div>
<div id="collect"></div>
"""
