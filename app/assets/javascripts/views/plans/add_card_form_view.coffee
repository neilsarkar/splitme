class SM.AddCardFormView extends SM.FormView
  initialize: (@user, @plan) ->
    super

  process: =>
    card = new SM.Card({
      card_number: @value("card-number")
      expiration_month: @value("expiration-month")
      expiration_year: @value("expiration-year")
    })

    card.save({
      success: (card_uri) =>
        SM.post(
          "/users/update"
          { card_uri: card_uri }
          {
            token: @user.token
            success: =>
              SM.Commitment.create(@user.token, @plan, {
                success: @success
                error: @error
              })
            error: @error
          }
        )
      error: @error
    })

  template: """
<input id='js-card-number' placeholder='Credit Card Number' />
<input id='js-expiration-month' class='month' placeholder='Exp. Month (MM)' type='tel'/>
<input id='js-expiration-year' class='year' placeholder='Exp. Year (YYYY)' type='tel'/>

<input type='submit' value="I'm in" class="btn btn-success" />
"""
