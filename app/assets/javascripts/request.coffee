SM.get = (path, options = {}) ->
  _.extend(options, {
    url: "#{window.config.urls.api}#{path}"
    headers: { 'X-Access-Token': options.token }
    type: "GET"
    contentType: "application/json"
  })

  if errorCallback = options.error
    options.error = (xhr) ->
      try
        errorCallback(JSON.parse(xhr.responseText).meta.errors, xhr.status, xhr)
      catch error
        errorCallback(xhr.responseText, xhr.status, xhr)

  if successCallback = options.success
    options.success = (json, worthless, xhr) ->
      successCallback(json.response, xhr.status, xhr)

  $.ajax(options)

SM.post = (path, data = {}, options = {}) ->
  _.extend(options, {
    url: "#{window.config.urls.api}#{path}"
    data: JSON.stringify(data)
    headers: { 'X-Access-Token': options.token}
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

  if successCallback = options.success
    options.success = (json, worthless, xhr) ->
      successCallback(json.response, xhr.status, xhr)

  $.ajax(options)
