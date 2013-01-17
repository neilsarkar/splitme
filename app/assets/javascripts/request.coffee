SM.get = (path, options = {}) ->
  options.method = "GET"
  SM.request(path, null, options)

SM.post = (path, data = {}, options = {}) ->
  options.method = "POST"
  SM.request(path, data, options)

SM.request = (path, data = null, options = {}) ->
  options.token ||= SM.Session.user?.token
  _.extend(options, {
    url: "#{window.config.urls.api}#{path}"
    headers: { 'X-Access-Token': options.token }
    type: options.method
    contentType: "application/json"
  })

  if data
    _.extend(options, {
      dataType: "json"
      data: JSON.stringify(data)
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
