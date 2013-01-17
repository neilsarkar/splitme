class SM.BaseView extends Backbone.View
  views: {}

  render: =>
    @trigger("pre_render")

    @renderTemplate()
    @renderSubviews()

    @trigger("render")
    @

  renderTemplate: =>
    html = Mustache.to_html(@template, @toJSON())
    @$el.empty()
    @$el.html(html)

  renderSubviews: =>
    _.each @subviews, (element, view_name) =>
      view = @views[view_name]
      $element = @$(element)
      return console.error("No view named #{view_name}") unless view
      return console.error("No element found for selector #{element}") unless $element.length
      view.setElement($element)
      view.render()

  close: =>
    if @subviews
      subview.close() for subview in @views
      delete @subviews

    @remove()
    @unbind()
    @trigger("close")
    delete this

  template: "<p>No template provided</p>"

  toJSON: =>
    {}
