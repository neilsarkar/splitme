class SM.ParticipantsView extends SM.BaseView
  initialize: (@plan) ->

  template: """
<div class='participant'>
  {{treasurer_name}}
</div>
{{#participants}}
  <div class='participant'>
    {{name}}
  </div>
{{/participants}}
"""

  toJSON: =>
    participants: @plan.participants
    treasurer_name: @plan.get("treasurer_name")
