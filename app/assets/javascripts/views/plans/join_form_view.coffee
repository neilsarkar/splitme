class SM.JoinFormView extends SM.BaseView
  events: {
    "click .toggle": "toggle_forms"
  }

  mappings: {
    "form": "form"
  }

  initialize: (@plan) ->
    @mode = "register"
    @views.form = new SM.RegisterFormView(@plan)

  template: """
<form action="javascript:void(0)" method="POST"></form>

<div class='center'>
  <a class='toggle' href='javascript:void(0)'>I have a password and want to sign in</a>
</div>
"""

  toggle_forms: (e) =>
    @views.form.close()
    if @mode == "sign_in"
      @mode = "register"
      $(e.target).html("JK, I do have an account.")
      @views.form = new SM.RegisterFormView(@plan)
    else
      @mode = "sign_in"
      $(e.target).html("JK, I don't have an account.")
      @views.form = new SM.SignInFormView(@plan)
    @render()
