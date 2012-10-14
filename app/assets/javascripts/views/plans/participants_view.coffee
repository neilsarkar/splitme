class SM.ParticipantsView extends SM.BaseView
  initialize: (@plan) ->

  template: """
{{#participants}}
  <div class='participant'>
    {{name}}
  </div>
{{/participants}}
"""

  toJSON: =>
    participants: @plan.participants
