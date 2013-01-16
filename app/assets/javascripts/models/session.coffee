SM.Session = {
  setUser: (user) ->
    SM.Session.user = user
    Cookie.set("token", user.token)

  start: ->
    if token = Cookie.get("token")
      deferred = SM.User.me(token)
      deferred.done (response) ->
        SM.Session.user = response.response
    else
      deferred = new jQuery.Deferred
      deferred.resolve()
    deferred
}
