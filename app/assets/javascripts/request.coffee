SM.get = (url, options = {}) ->
  _.extend(options, {
    url: url
    headers: { 'X-Access-Token': SM.token() }
    type: "GET"
    contentType: "application/json"
  })

  if errorCallback = options.error
    options.error = (xhr) ->
      errorCallback(JSON.parse(xhr.responseText).meta.errors, xhr.status, xhr)

  $.ajax(options)

SM.post = (url, data = {}, options = {}) ->
  _.extend(options, {
    url: url
    data: JSON.stringify(data)
    headers: { 'X-Access-Token': SM.token()}
    type: "POST"
    dataType: "json"
    contentType: "application/json"
  })

  if errorCallback = options.error
    options.error = (xhr) ->
      try
        errorCallback(JSON.parse(xhr.responseText).meta.errors, xhr.status, xhr)
      catch error
        errorCallback(xhr.responseText, xhr.status, xhr)

  $.ajax(options)

SM.token = () ->
  ""
