class SM.Base extends Backbone.Model
  fetch: =>
    @fetched = super

  parse: (json) ->
    json.response
