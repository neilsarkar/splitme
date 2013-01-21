class SM.Participant extends SM.Base
  initialize: ->

  charge: (plan_id) =>
    SM.post("/plans/#{plan_id}/charge/#{@id}")

  @new: (json) ->
    if json instanceof Array
      return json if json[0] instanceof SM.Participant
      _.map json, (participant) ->
        new SM.Participant(participant)
    else
      return json if json instanceof SM.Participant
      new SM.Participant(json)

  @all: =>
    SM.get("/plans")

  @create: (attributes) =>
    SM.post("/plans", plan: attributes)

  @find: (id) =>
    SM.get("/plans/#{id}")
