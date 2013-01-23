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
    "plans/:id": "plans_admin"
    "payment_information": "payment_information"
    "connect_with_groupme/:groupme_token": "connect_with_groupme"
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

  plans_admin: (plan_id) =>
    @require_user (user) =>
      view = new SM.AdminPlanView(user, plan_id)
      @show(view)

  payment_information: =>
    @require_user (user) =>
      view = new SM.PaymentInformationView
      @show(view)

  connect_with_groupme: (groupme_token) =>
    SM.User.convert_groupme_token(groupme_token, {
      success: (user) =>
        SM.Session.setUser(user)
        window.app.navigate("/plans", triggerRoute=true)
      error: =>
        debugger
        # @navigate("", triggerRoute=true)
    })

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
    $page.append(@view.el)
    @view.render()

  teardown: =>
    @view?.close()
    @view = null
