SM.Session = {
  setUser: (user) ->
    SM.Session.user = user
    Cookie.set("token", user.token)

  getUser: (callback) ->
    if SM.Session.user
      return callback(SM.Session.user)
    else if Cookie.get("token")
      SM.User.me(Cookie.get("token"), {
        success: (user) ->
          SM.Session.user = user
          callback(user)
        error: ->
          callback(null)
      })
    else
      return callback(null)
}
