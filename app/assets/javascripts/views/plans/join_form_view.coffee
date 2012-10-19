class SM.JoinFormView extends SM.BaseView
  events: {
    "submit form": "process"
    "focus input": "clear_invalid"
    "click .toggle": "toggle_forms"
  }

  initialize: (@plan) ->
    @on "pre_render", =>
      @template = @lockedTemplate if @plan.get("is_locked")
    @mode = "register"

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

  lockedTemplate: """
<div class="disclaimer">
  <p>
    Sorry, this plan has already been split.
  </p>
  <p>
    If you're already in, enjoy! If not, Ya burnt!
  </p>
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
    if @mode == "sign_in"
      charge = new SM.Charge(
        {
          email: @$("#js-signin-email").val()
          password: @$("#js-signin-password").val()
        }
        @plan
      )

      charge.create_from_sign_in({
        success: (message) =>
          @form().alertSuccess(message)
        error: (message) =>
          @form().alertError(message)
      })
    else
      @validate()
      if @$("input.invalid").length
        return @form().alertError("Please correct the fields in red")

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

      charge.create({
        success: (message) =>
          @form().alertSuccess(message)
        error: (message) =>
          @form().alertError(message)
      })

  clear_invalid: (e) =>
    $(e.target).removeClass("invalid")

  validate: =>
    _.each @form().find("input"), (el) =>
      $el = $(el)
      $el.toggleClass("invalid", $el.val().length == 0)

    @validate_card_number(@$("#js-card-number"))
    @validate_dates(@$("#js-expiration-month"), @$("#js-expiration-year"))
    @validate_email(@$("#js-email"))
    @validate_phone_number(@$("#js-phone-number"))

  validate_card_number: ($el) =>
    unless balanced.card.isCardNumberValid($el.val())
      $el.addClass("invalid")

  validate_dates: ($month_el, $year_el) =>
    unless balanced.card.isExpiryValid($month_el.val(), $year_el.val())
      $month_el.addClass("invalid")
      $year_el.addClass("invalid")

  validate_email: ($el) =>
    @email_regex ?= /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    unless @email_regex.test($el.val())
      $el.addClass("invalid")

  validate_phone_number: ($el) =>
    digit_length = $el.val().replace(/[^\d]/g, '').length
    unless digit_length == 10 || digit_length == 11
      $el.addClass("invalid")
