class SM.Plan extends SM.Base
  fetch_from_token: (options)=>
    _.extend(options, {
      url: "#{window.config.urls.api}/plans/#{@get('token')}/preview"
    })

    @fetch(options)
