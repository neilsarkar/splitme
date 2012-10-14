class SM.JoinView extends SM.BaseView
  events: {
    "submit form": "process"
    "focus input": "clearInvalid"
  }

  initialize: (@plan) ->

  template: """
<form action='javascript:void(0)' method="POST">
  <label for='js-name'>Name</label>
  <input id='js-name' placeholder='Name' />

  <label for='js-email'>Email</label>
  <input id='js-email' placeholder='Email' />

  <label for='js-phone-number'>Phone Number</label>
  <input id='js-phone-number' placeholder='Phone Number'/>

  <label for='js-card-number'>Credit Card Number</label>
  <input id='js-card-number' placeholder='Credit Card Number' />

  <label for='js-expiration-month'>Expiration Date</label>
  <input id='js-expiration-month' placeholder='MM' />
  <input id='js-expiration-year' placeholder='YYYY' />

  <br />
  <br />
  <input type='submit' value="I'm in" class='btn btn-success'/>
</form>
"""

  process: =>
    @validate()
    return if @$("input.invalid").length

    participant = new SM.Participant
    participant.create({
      name: @$("#js-name").val()
      email: @$("#js-email").val()
      phone_number: @$("#js-phone-number").val()
      card_number: @$("#js-card-number").val()
      expiration_month: @$("#js-expiration-month").val()
      expiration_year: @$("#js-expiration-year").val()
    }, @plan)

  clearInvalid: (e) =>
    $(e.target).removeClass("invalid")

  validate: =>
    _.each @$("input"), (el) =>
      $el = $(el)
      $el.toggleClass("invalid", $el.val().length == 0)

    @validateCardNumber(@$("#js-card-number"))
    @validateDates(@$("#js-expiration-month"), @$("#js-expiration-year"))
    @validateEmail(@$("#js-email"))
    @validatePhoneNumber(@$("#js-phone-number"))

  validateCardNumber: ($el) =>
    $el.toggleClass("invalid", !balanced.card.isCardNumberValid($el.val()))

  validateDates: ($month_el, $year_el) =>
    unless balanced.card.isExpiryValid($month_el.val(), $year_el.val())
      $month_el.addClass("invalid")
      $year_el.addClass("invalid")

  validateEmail: ($el) =>
    @email_regex ?= /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    $el.toggleClass("invalid", !@email_regex.test($el.val()))

  validatePhoneNumber: ($el) =>
    digit_length = $el.val().replace(/[^\d]/g, '').length
    unless digit_length == 10 || digit_length == 11
      $el.addClass("invalid")
