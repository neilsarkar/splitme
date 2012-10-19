class SM.JoinFormView extends SM.BaseView
  events: {
    "submit form": "process"
    "focus input": "clearInvalid"
  }

  initialize: (@plan) ->
    @on "pre_render", =>
      @template = @lockedTemplate if @plan.get("is_locked")

  template: """
<form action='javascript:void(0)' method="POST">
  <input id='js-name' placeholder='Name' />

  <input id='js-email' placeholder='Email' />

  <input id='js-phone-number' placeholder='Phone Number'/>

  <input id='js-card-number' placeholder='Credit Card Number' />

  <input id='js-expiration-month' class='month' placeholder='Exp. Month (MM)' type='tel'/>
  <input id='js-expiration-year' class='year' placeholder='Exp. Year (YYYY)' type='tel'/>

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

  process: =>
    @$("form").disableForm()
    @validate()
    if @$("input.invalid").length
      return @$("form").alertError("Please correct the fields in red")

    charge = new SM.Charge(
      {
        name: @$("#js-name").val()
        email: @$("#js-email").val()
        phone_number: @$("#js-phone-number").val()
        card_number: @$("#js-card-number").val()
        expiration_month: @$("#js-expiration-month").val()
        expiration_year: @$("#js-expiration-year").val()
      }
      @plan
    )

    charge.create({
      success: (message) =>
        @$("form").alertSuccess(message)
      error: (message) =>
        @$("form").alertError(message)
    })

  clearInvalid: (e) =>
    $(e.target).removeClass("invalid")

  validate: =>
    _.each @$("input"), (el) =>
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
