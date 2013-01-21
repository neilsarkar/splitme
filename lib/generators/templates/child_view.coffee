class SM.ChildView extends SM.Baseview
  initialize: (options) ->
    @delegate = options.delegate || this
    @model = options.model

  toJSON: =>
    # hash of values for mustache template

  delegatedAction: =>
    @delegate.customAction()

  customAction: =>
    # You can implement actions here or in the parent view

  events: {
    "click div": "delegatedAction"
  }

  template: """
<div>
  This is a subview.
</div>
"""
