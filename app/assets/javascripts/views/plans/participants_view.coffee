class SM.ParticipantsView extends SM.BaseView
  initialize: (@plan) ->

  template: """
<h3>Who's in?</h3>
 {{#participants}}
  <div class='participant'>
    {{name}}
  </div>
{{/participants}}
"""

  toJSON: =>
    participants: @plan.participants
