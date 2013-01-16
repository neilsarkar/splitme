class SM.LogInView extends SM.FormView
  process: =>
    @$el.disableForm()

    SM.User.authenticate(@value("email"), @value("password"), {
      success: (user) =>
        SM.Session.setUser(user)
        window.app.navigate("/plans", triggerRoute=true)
      error: =>
        @error("Sorry, your email or password is incorrect.")
    })


  template: """
<h1> Log In </h1>
<input type="text" id="js-email" placeholder="Email" />
<input type="password" id="js-password" placeholder="Password" />
<input type="submit" value="Log In"/>
"""
