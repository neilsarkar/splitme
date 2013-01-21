class SM.CollectView extends SM.BaseView
  initialize: (@plan, options) ->
    @delegate = options.delegate || this
    @plan.on("change", @render)

  toJSON: =>
    if @plan.get("is_locked")
      label: "Collect"
    else
      label: "Get Money"

  events: {
    "click #collect": "collect"
  }

  collect: =>
    if @plan.get("is_locked")
      @plan.collect().done( =>
        $.flash("You did it!")
        $("#page").html("You did it!")
      ).error( =>
        $.flash("Sorry, something went wrong. Please try again or email support@splitmeapp.com")
      )
    else
      @delegate.chargeCards()

  template: """
<div class="collect">
  <a id="collect" href="javascript:void(0)">{{label}}</a>
</div>
"""
