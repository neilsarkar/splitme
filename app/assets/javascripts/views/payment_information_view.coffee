class SM.PaymentInformationView extends SM.FormView
  initialize: ->
    super
    @user = SM.Session.user

  toJSON: =>
    @user

  process: =>
    @$el.disableForm()
    bankData = {
      bank_code: @value("bank_routing_number")
      account_number: @value("bank_account_number")
      street_address: @value("street_address")
      postal_code: @value("zip_code")
      dob: "#{@value("month")}/#{@value("year")}"
      name: @user.name
      phone_number: @user.phone_number
      email: @user.email
    }
    bankAccount = new SM.BankAccount(bankData)
    bankAccount.save(
      error: @error
      success: (bankAccountUri) =>
        # Update our bro
        SM.User.update(@user.token, {
          bank_account_uri: bankAccountUri
          zip_code: @value("zip_code")
          date_of_birth: "#{@value("month")}/#{@value("year")}}"
          street_address: @value("street_address")
        }).done( ->
          window.app.navigate("plans", triggerRoute=true)
          $.flash("Cool, your bank account is linked now.")
        ).error( ->
          @error("Sorry, something went wrong in linking your bank account. Please try again or email support@splitmeapp.com")
        )
    )

  template: """
<h1>Link your Bank Account</h1>
<input name="bank_routing_number" placeholder="Bank Routing Number"/>
<input name="bank_account_number" placeholder="Bank Account Number"/>
<input name="street_address" placeholder="Street Address"/>
<input name="zip_code" placeholder="Zip Code"/>
Date of Birth:
<input name="month" type="tel" placeholder="MM"/>
<input name="day" type="tel" placeholder="DD"/>
<input name="year" type="tel" placeholder="YYYY"/>
<input type="submit" class="btn btn-success" value="Link Bank Account"/>

<img src="/assets/balanced.png" class="balanced"/>

<p>
  Note: We will only use your bank account
  information to post credits to your account.
</p>
"""
