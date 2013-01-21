class SM.AdminParticipantsView extends SM.BaseView
  initialize: (@plan) ->

  template: """
{{#participants}}
  <div class="participant">
    <label for="participant-{{id}}" class="name">{{name}}</label>
    <div class="status">
      <input type="checkbox" id="participant-{{id}}" />
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
    participants: @plan.get("participants")
