class SM.User

SM.User.authenticate = (email, password, options = {}) ->
  SM.post(
    "/users/authenticate"
    { user: { email: email, password: password } }
    options
  )

SM.User.me = (token, options = {}) ->
  SM.get(
    "/me?token=#{token}"
    options
  )
