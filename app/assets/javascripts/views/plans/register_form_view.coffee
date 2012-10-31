class SM.RegisterFormView extends SM.FormView
  initialize: (@plan) ->
    super

  toJSON: =>
    creator_name: @plan.get("treasurer_name")
    price_per_person: @plan.get("price_per_person")

  process: =>
    @$el.disableForm()

    unless @validate()
      return @error("Please correct the fields in red")

    charge = new SM.Charge(
      {
        name: @value("name")
        email: @value("email")
        phone_number: @value("phone-number")
        card_number: @value("card-number")
        expiration_month: @value("expiration-month")
        expiration_year: @value("expiration-year")
        password: @value("password")
      }
      @plan
    )

    charge.create(success: @success, error: @error)

  validate: =>
    @form_validator.validate_presence()
    @form_validator.validate_card_number(@$("#js-card-number"))
    @form_validator.validate_dates(@$("#js-expiration-month"), @$("#js-expiration-year"))
    @form_validator.validate_email(@$("#js-email"))
    @form_validator.validate_phone_number(@$("#js-phone-number"))
    @form_validator.valid()

  template: """
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
"""
