class SM.JoinView extends SM.BaseView
  mappings: {
    "price_breakdown": "#price-breakdown"
    "participants": "#participants"
    "join_form": "#join"
  }

  initialize: (token) ->
    @plan = new SM.Plan(token: token)
    @views.price_breakdown = new SM.PriceBreakdownView(@plan)
    @views.participants = new SM.ParticipantsView(@plan)
    @views.join_form = new SM.JoinFormView(@plan)

    @plan.fetch_from_token(
      success: =>
        @render()
      error: =>
        @$el.html("<h1>Sorry, there's no plan at this URL. Please ask your friend for an updated one.</h1>")
    )

    @on "pre_render", =>
      @views.join_form = new SM.LockedView if @plan.get("is_locked")

    @on "render", =>
      @$(".description").autolink()

  template: """
<img src='/assets/header.png' class='header'/>
<div class='section'>
  <div class='invited'>You've been invited to join</div>
  <h1>
    {{title}}
    <span class='price'>{{total_price}}</span>
  </h1>
</div>
<div class='section'>
  <div class='description'>{{description}}</div>
  <div id='price-breakdown'></div>
</div>
<div class='participant section'>
  <div class='subheading'>Who's In</div>
  <div id='participants'></div>
  <div class='subheading'>Join In</div>
  <div id='join'></div>
</div>
"""

  toJSON: =>
    @plan?.toJSON()
