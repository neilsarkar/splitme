class SM.User

SM.User.authenticate = (email, password, options = {}) ->
  SM.post(
    "/users/authenticate"
    { user: { email: email, password: password } }
    options
  )
