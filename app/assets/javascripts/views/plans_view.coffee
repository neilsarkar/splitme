class SM.PlansView extends SM.BaseView
  initialize: (@user) ->

  toJSON: =>
    name: @user.name

  template: """
  <h1>Welcome, {{name}}</h1>
"""
