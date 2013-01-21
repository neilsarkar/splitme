class SM.FormView extends SM.BaseView
  tagName: "form"

  events: {
    "submit": "process"
    "focus input": "clear_invalid"
  }

  initialize: ->
    @$el.attr({"action": "javascript:void(0)", "method": "POST"})
    @on "render", =>
      @form_validator = new SM.FormValidator(@$el)

  process: =>
    # an exercise for the reader...

  clear_invalid: (e) =>
    @form_validator.clear(e.target)

  success: (message) =>
    @$el.alertSuccess(message)
    @$("input").remove()

  error: (message) =>
    @$el.alertError(message)

  value: (field_name) =>
    @$("#js-#{field_name}, [name=#{field_name}]").val()
