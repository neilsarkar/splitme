class SM.FormValidator
  constructor: ($form) ->
    @set_form($form)

  set_form: (@$form) =>

  validate: =>
    _.each @$form.find("input"), (el) =>
      $el = $(el)
      $el.toggleClass("invalid", $el.val().length == 0)

  valid: =>
    @$form.find("invalid").length == 0

  clear_all: =>
    @clear(@$form.find("input"))

  validate_email: ($el) =>
    @email_regex ?= /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    unless @email_regex.test($el.val())
      $el.addClass("invalid")

  validate_card_number: ($el) =>
    unless balanced.card.isCardNumberValid($el.val())
      $el.addClass("invalid")

  validate_dates: ($month_el, $year_el) =>
    unless balanced.card.isExpiryValid($month_el.val(), $year_el.val())
      $month_el.addClass("invalid")
      $year_el.addClass("invalid")

  validate_phone_number: ($el) =>
    digit_length = $el.val().replace(/[^\d]/g, '').length
    unless digit_length == 10 || digit_length == 11
      $el.addClass("invalid")

  clear: (el) =>
    $(el).removeClass("invalid")
