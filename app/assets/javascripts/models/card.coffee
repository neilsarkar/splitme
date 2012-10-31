class SM.Card
  initialize: (card_number, expiration_month, expiration_year) ->
    @payment_attributes = {
      card_number: card_number
      expiration_month: expiration_month
      expiration_year: expiration_year
    }

  save: (options = {}) =>
    options.error   ?= console.error
    options.success ?= console.log

    balanced.card.create @payment_attributes, (response) =>
      switch response.status
        when 201
          options.success(response.data.uri)

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
