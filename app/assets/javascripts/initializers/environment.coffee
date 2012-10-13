window.SM ?= {}

window.config = {}
window.config.host = window.location.href.match("(https?:\/\/.*?)(\/|$)")[1]

if window.config.host.match("splitmeapp.com")
  window.config.env = "production"
else if window.config.host.match("splitme.dev")
  window.config.env = "development"
