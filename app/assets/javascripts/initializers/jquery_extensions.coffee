$.fn.alertError = (message) ->
  $(this).alertMessage(message || "Sorry, something went wrong. Try again or contact support@splitmeapp.com", "alert-error")

$.fn.alertSuccess = (message) ->
  $(this).alertMessage(message, "alert-success")

$.fn.alertMessage = (message, htmlClass) ->
  unless $(this).is("form")
    throw "Tried to call alertError outside of a form"

  if message instanceof Object
    arr = []
    for key, val of message
      arr.push("#{key}: #{val}")
    message = arr.join("<br />")
  else if message instanceof Array
    message = message.join("<br />")

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

$.fn.autolink = ->
  this.each ->
    el = $(this)
    if el.html() && !el.find('a').length
      regex = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
      linkedText = el.html().replace(regex, "<a href='$1' target='_blank'>$1</a>")
      el.html(linkedText)
