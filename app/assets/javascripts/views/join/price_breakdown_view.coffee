class SM.PriceBreakdownView extends SM.BaseView
  initialize: (@plan) ->

  template: """
{{#breakdown}}
  <div class="line {{#current}}current{{/current}} {{#next}}next{{/next}}">
    <div class="people">
      {{people}} People
    </div>
    <div class="price">
      {{price_per_person}} / Person
    </div>
  </div>
{{/breakdown}}
"""

  toJSON: =>
    breakdown: @plan.get "breakdown"
