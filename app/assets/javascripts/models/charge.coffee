class SM.Charge
  constructor: (@attributes, @plan) ->
    @user_attributes = _.pick(@attributes, 'name', 'email', 'phone_number')
    @payment_attributes = _.pick(@attributes, 'card_number', 'expiration_month', 'expiration_year')

  create: (options = {}) =>
    options.error ?= console.error
    options.success ?= console.log

    balanced.card.create @payment_attributes, (response) =>
      switch response.status
        when 201
          @user_attributes.card_uri = response.data.uri
          @join_plan(options)

        when 400 # missing field(s)
          options.error(response.error)

        when 402 # card failed
          options.error(response.error)

        when 403 # field(s) formatted incorrectly
          options.error(response.error)

        when 404 # marketplace uri is wrong
          options.error("Something is wrong with our system. Please try again later.")
          console.error(response.error)

        when 409 # card is a dupe
          options.error(response.error)

        when 500
          options.error("Something went wrong with our payments provider. Please try again")
          console.error(response.error)


  join_plan: (options) =>
    SM.post(
      "#{window.config.urls.api}/participants/#{@plan.get('token')}/create"
      participant: @user_attributes
      {
        success: =>
          options.success("Awesome, you're in.")
        error: (errors, code, xhr) =>
          options.error(errors)
      }
    )
