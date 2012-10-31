class SM.SignInFormView extends SM.FormView
  initialize: (@plan) ->
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
            # @mode = "register"
            # @$("form").toggle()
            # @form().alertError("It looks like we don't have a credit card saved for you.")
            # @$("#js-email, #js-name, #js-phone-number, #js-password").remove()
            # @token = user.token
        error: @error
      }
    )

  template: """
<input name='email' id='js-email' placeholder='Email'/>
<input name='password' id='js-password' type='password' placeholder='Password'/>
<input type='submit' value="I'm in" class="btn btn-success" />
"""
