class SM.App extends Backbone.Router
  view: null

  routes:
    "" : "home"
    "log_in": "log_in"
    ":token": "join"

  route: (route, name, callback) =>
    super(route, name, =>
      @teardown()
      document.body.className = "#{name}"
      callback.apply(this, arguments)
    )

  show: (view) =>
    @view = view
    $page = $("#page")
    $page.empty()
    $page.append(@view.render().el)

  teardown: =>
    @view?.close()
    @view = null

  home: =>
    view = new SM.HomeView
    @show(view)

  join: (token) =>
    view = new SM.JoinView(token)
    @show(view)

  log_in: =>
    view = new SM.LogInView
    @show(view)
