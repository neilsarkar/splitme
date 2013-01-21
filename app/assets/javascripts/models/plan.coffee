class SM.Plan extends SM.Base
  initialize: ->
    @url = "#{window.config.urls.api}/plans/#{@id}?token=#{SM.Session.user?.token}"

  fetch_from_token: (options)=>
    _.extend(options, {
      url: "#{window.config.urls.api}/plans/#{@get('token')}/preview"
    })

    @fetch(options)

  parse: (json) =>
    json = super(json)
    @participants = json.participants
    delete json.participants
    json

  charge: =>
    ajaxRequests = _.map @participants(), (participant) =>
      participant.charge(@id)

    $.when.apply($, ajaxRequests)

  collect: =>
    SM.post("/plans/#{@id}/collect")

  participants: =>
    SM.Participant.new(@get("participants"))

  @new: (json) =>
    if json instanceof Array
      return json if json[0] instanceof SM.Plan
      _.map json, (plan) ->
        new SM.Plan(plan)
    else
      return json if json instanceof SM.Plan
      new SM.Plan(json)

  @all: =>
    SM.get("/plans")

  @create: (attributes) =>
    SM.post("/plans", plan: attributes)

  @find: (id) =>
    SM.get("/plans/#{id}")
