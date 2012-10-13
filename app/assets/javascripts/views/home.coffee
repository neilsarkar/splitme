class SM.HomeView extends SM.BaseView
  mappings: {
    "sub_view": "#subview"
  }

  initialize: () ->
    @views.sub_view = new SM.BaseView

  template: """
    <h1>Hello turds.</h1>
    <div id='subview'></div>
  """
