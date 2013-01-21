class SM.<%= class_name%>View extends SM.BaseView # or extend FormView
  initialize: (@model) ->
    # This method is optional. You can set up subviews here:
    @views.example = new SM.ChildView(model: @model, delegate: this)

    # You can also set up bindings here, e.g.
    # @model.on("change", @render)

  toJSON: =>
    # This method should return a hash of values for Mustache to
    #  plug in to the template defined below
    name: "Hi"

  subviews: {
    # map subview objects to css selected DOM elements
    "example": "#example_subview"
  }

  events: {
    # map events to css selected DOM elements
    #  (provided by Backbone)
    "click a": "customAction"
  }

  customAction: =>
    console.log("You did it!")

  template: """
<div>
  <a href="javascript:void(0)">{{name}}</a>
  <div id="example_subview"></div>
</div>
"""
