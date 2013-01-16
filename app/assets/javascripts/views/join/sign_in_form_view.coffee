class SM.SignInFormView extends SM.FormView
  initialize: (@plan, @callback) ->
    super

  process: =>
    email = @value("email")
    password = @value("password")
    SM.User.authenticate(email, password,
      {
        success: (user) =>
          if user.has_card
            SM.Commitment.create(user.token, @plan, { success: @success, error: @error })
          else
            @callback(user)
        statusCode: {
          404: =>
            @error("Sorry, we couldn't find the email nope@crap.com in our system.")
          401: =>
            @error("Your password is incorrect.")
        }
        error: @error
      }
    )

  template: """
<input name='email' id='js-email' placeholder='Email'/>
<input name='password' id='js-password' type='password' placeholder='Password'/>
<input type='submit' value="I'm in" class="btn btn-success" />
"""
