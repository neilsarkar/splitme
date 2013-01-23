class SM.Location
  @store: (path) ->
    path ?= Backbone.history.fragment
    SM.Location.path = path

  @redirectBack: (options = {}) ->
    if SM.Location.path
      window.app.navigate(SM.Location.path, triggerRoute=true)
      delete SM.Location.path
    else if options.default
      window.app.navigate(options.default, triggerRoute=true)
    else
      console.error("No redirect location specified")
