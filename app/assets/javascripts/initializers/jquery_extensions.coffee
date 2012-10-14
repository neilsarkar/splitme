$.fn.alertError = (message) ->
  $(this).alertMessage(message || "Sorry, something went wrong. Try again or contact support@splitmeapp.com", "alert-error")

$.fn.alertSuccess = (message) ->
  $(this).alertMessage(message, "alert-success")

$.fn.alertMessage = (message, htmlClass) ->
  unless $(this).is("form")
    throw "Tried to call alertError outside of a form"

  $(this).enableForm()
  $(this).clearMessage()
  $alert = $("<div class='alert #{htmlClass}'></div>")
  $alert.html(message)
  $alert.prepend("<button class='close' data-dismiss='alert'>&times;</button>")
  $(this).prepend($alert)

$.fn.clearMessage = ->
  $(this).find(".alert").remove()

$.fn.disableForm = ->
  form = $(this)
  form.attr("disabled", "disabled")
  form.find(".btn").addClass("disabled")

$.fn.enableForm = ->
  form = $(this)
  form.removeAttr("disabled")
  form.find(".btn").removeClass("disabled")

$.fn.dotdotdot = ->
  baseHtml = @html()
  setInterval =>
    return unless @is(":visible")
    if @html().indexOf("...") == -1
      @html(@html() + ".")
    else
      @html(baseHtml)
  , 300
