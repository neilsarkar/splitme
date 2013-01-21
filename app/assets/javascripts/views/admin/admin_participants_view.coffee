class SM.AdminParticipantsView extends SM.BaseView
  initialize: (@plan) ->
    @plan.on("collection:success", @render)
    @plan.on("collection:failed", @render)

  template: """
{{#participants}}
  <div class="participant">
    <label for="participant-{{id}}" class="name">{{name}}</label>
    <div class="status" id="participant-status-{{id}}">
      {{#isChargeable}}
        <input type="checkbox" id="participant-{{id}}" />
      {{/isChargeable}}
      {{#isCharged}}
        <span class="success">&#10004;</span>
      {{/isCharged}}
      {{#isFailed}}
        <span class="fail">&#10006;</span>
      {{/isFailed}}
    </div>
    <div class="contact-info">
      <div class="phone-number">
        {{phone_number}}
      </div>
      <div class="email">
        {{email}}
      </div>
    </div>
  </div>
{{/participants}}
"""

  toJSON: =>
    # God damnit mustache, not having conditional logic
    participants = _.map @plan.get("participants"), (participant) ->
      participant.isChargeable = (participant.state == "unpaid" || participant.state == "failed")
      participant.isCharged    = (participant.state == "escrowed" || participant.state == "collected")
      participant.isFailed     = participant.state == "failed"
      participant
    participants: participants
