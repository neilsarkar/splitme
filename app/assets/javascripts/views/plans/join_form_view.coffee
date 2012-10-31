class SM.JoinFormView extends SM.BaseView
  events: {
    "submit form": "process"
    "focus input": "clear_invalid"
    "click .toggle": "toggle_forms"
  }

  initialize: (@plan) ->
    @mode = "register"
    @on "render", =>
      @form_validator = new SM.FormValidator(@form())

  template: """
<form action='javascript:void(0)' method="POST" class='register'>
  <input id='js-name' placeholder='Name' />
  <input id='js-email' placeholder='Email' />
  <input id='js-phone-number' placeholder='Phone Number'/>

  <input id='js-card-number' placeholder='Credit Card Number' />
  <input id='js-expiration-month' class='month' placeholder='Exp. Month (MM)' type='tel'/>
  <input id='js-expiration-year' class='year' placeholder='Exp. Year (YYYY)' type='tel'/>

  <input id='js-password' placeholder='Set a password' type='password'/>

  <div class="disclaimer">
    <p>
      The current price per person is {{price_per_person}}.
    </p>
    <p>
      This price will go down if more people join.
    </p>
    <p>
      Your card will NOT be charged a dime until {{creator_name}} decides to collect.
    </p>
  </div>

  <input type='submit' value="I'm in" class='btn btn-success'/>
</form>

<form action='javascript:void(0)' method='POST' style='display:none' class='sign_in'>
  <input name='email' id='js-signin-email' placeholder='Email'/>
  <input name='password' id='js-signin-password' type='password' placeholder='Password'/>
  <input type='submit' value="I'm in" class="btn btn-success" />
</form>

<div class='center'>
  <a class='toggle' href='javascript:void(0)'>I have a password and want to sign in</a>
</div>
"""

  toJSON: =>
    creator_name: @plan.get("treasurer_name")
    price_per_person: @plan.get("price_per_person")

  toggle_forms: (e) =>
    if @mode == "sign_in"
      @mode = "register"
      $(e.target).html("JK, I do have an account.")
    else
      @mode = "sign_in"
      $(e.target).html("JK, I don't have an account.")
    @$("form").toggle()

  form: =>
    @$("form.#{@mode}")

  process: =>
    @form().disableForm()
    options = {
      success: (message) =>
        @form().alertSuccess(message)
        @$("form input").remove()
      error: (message) =>
        @form().alertError(message)
    }

    if @mode == "sign_in"
      charge = new SM.Charge(
        {}
        @plan
      )

      SM.post(
        "/users/authenticate"
        {
          email: @$("#js-signin-email").val(),
          password: @$("#js-signin-password").val()
        }
        {
          success: (user) =>
            if user.has_card
              charge.join_plan(user.token, options)
            else
              @mode = "register"
              @$("form").toggle()
              @form().alertError("It looks like we don't have a credit card saved for you.")
              @$("#js-email, #js-name, #js-phone-number, #js-password").remove()
              @token = user.token
          error: options.error
        }
      )
    else
      @validate()
      unless @form_validator.valid()
        return @form().alertError("Please correct the fields in red")

      if @token
        charge = new SM.Charge(
          {
            token: @token
            card_number: @$("#js-card-number").val()
            expiration_month: @$("#js-expiration-month").val()
            expiration_year: @$("#js-expiration-year").val()
          },
          @plan
        )
      else
        charge = new SM.Charge(
          {
            name: @$("#js-name").val()
            email: @$("#js-email").val()
            phone_number: @$("#js-phone-number").val()
            card_number: @$("#js-card-number").val()
            expiration_month: @$("#js-expiration-month").val()
            expiration_year: @$("#js-expiration-year").val()
            password: @$("#js-password").val()
          }
          @plan
        )

      charge.create(options)

  clear_invalid: (e) =>
    @form_validator.clear(e.target)

  validate: =>
    @form_validator.validate_card_number(@$("#js-card-number"))
    @form_validator.validate_dates(@$("#js-expiration-month"), @$("#js-expiration-year"))
    unless @token
      @form_validator.validate_email(@$("#js-email"))
      @form_validator.validate_phone_number(@$("#js-phone-number"))
