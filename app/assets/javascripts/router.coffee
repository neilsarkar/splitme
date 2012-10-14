class SM.App extends Backbone.Router
  view: null

  routes:
    "" : "home"
    ":token": "show_plan"

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

  show_plan: (token) =>
    view = new SM.PlanView(token)
    @show(view)
