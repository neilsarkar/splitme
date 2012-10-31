class SM.Charge
  constructor: (@attributes, @plan) ->
    @user_attributes = _.pick(@attributes, 'name', 'email', 'phone_number', 'password')
    @payment_attributes = _.pick(@attributes, 'card_number', 'expiration_month', 'expiration_year')
    @token = @attributes.token

  create: (options = {}) =>
    options.error ?= console.error
    options.success ?= console.log

    balanced.card.create @payment_attributes, (response) =>
      switch response.status
        when 201
          if @token
            @update_user(
              @token,
              { user: { card_uri: response.data.uri } },
              success: (user) =>
                SM.Commitment.create(@token, @plan, options)
              error: (errors, code, xhr) =>
                options.error(errors)
            )
          else
            @user_attributes.card_uri = response.data.uri
            @create_user(
              success: (user) =>
                SM.Commitment.create(user.token, @plan, options)
              error: (errors, code, xhr) =>
                options.error(errors)
            )

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

  update_user: (token, data, options = {}) =>
    options.token = token
    SM.post(
      "/users/update"
      data
      options
    )

  create_user: (options = {}) =>
    SM.post(
      "/users"
      @user_attributes
      options
    )
