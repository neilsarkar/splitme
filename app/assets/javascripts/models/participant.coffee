class SM.Participant extends SM.Base
  create: (attributes, @plan) =>
    @attributes = _.pick(attributes, 'name', 'email', 'phone_number')
    payment_attributes = _.pick(attributes, 'card_number', 'expiration_month', 'expiration_year')
    balanced.card.create payment_attributes, (response) =>
      switch response.status
        when 201
          @attributes.card_uri = response.data.uri
          @join_plan()

        when 400 # missing field(s)
          console.error(response.error)

        when 402 # card failed
          console.error(response.error)

        when 403 # field(s) formatted incorrectly
          console.error(response.error)

        when 404
          alert("Something went wrong, sorry.")

        when 409
          console.error(response.error)

        when 500
          alert("Something went wrong, please try again")

  join_plan: =>
    SM.post(
      "#{window.config.urls.api}/plans/#{@plan.get('token')}/join"
      @attributes
      {
        success: =>
          alert("Awesome, you're in.")
        error: =>
          alert("You suck.")
      }
    )

