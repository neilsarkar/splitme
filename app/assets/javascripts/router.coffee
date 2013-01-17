class SM.App extends Backbone.Router
  start: =>
    SM.Session.start().always ->
      Backbone.history.start({pushState: true})

  # Routes
  routes:
    "" : "home"
    "log_in": "log_in"
    "plans": "plans"
    "plans/new": "plans_new"
    ":token": "join"

  home: =>
    view = new SM.HomeView
    @show(view)

  join: (token) =>
    view = new SM.JoinView(token)
    @show(view)

  log_in: =>
    view = new SM.LogInView
    @show(view)

  plans: =>
    @require_user (user) =>
      view = new SM.PlansView(user)
      @show(view)

  plans_new: =>
    @require_user (user) =>
      view = new SM.NewPlanView(user)
      @show(view)

  require_user: (callback) =>
    if user = SM.Session.user
      callback(user)
    else
      @navigate("", triggerRoute=true)

  # Internals
  view: null

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
