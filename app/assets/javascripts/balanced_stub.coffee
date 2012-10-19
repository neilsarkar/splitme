class window.CardStub
  create: (attributes, callback) ->
    callback({
      status: 201
      data: {uri: "/cards/fake"}
    })

  isCardNumberValid: ->
    true

  isExpiryValid: ->
    true

class window.BalancedStub
  constructor: ->
    @card = new CardStub
