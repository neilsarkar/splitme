window.SM ?= {}

window.config = {}
window.config.host = window.location.href.match("(https?:\/\/.*?)(\/|$)")[1]
window.config.urls = {}

if window.config.host.match("splitmeapp.com")
  window.config.env = "production"
else if window.config.host.match("splitme.dev")
  window.config.env = "development"
else if window.config.host.match("127.0.0.1")
  window.config.env = "test"

if window.config.env == "production"
  window.config.urls.api = "http://api.splitmeapp.com"
else if window.config.env == "development"
  window.config.urls.api = "http://api.splitme.dev:3000"
else if window.config.env == "test"
  window.config.urls.api = "http://api.splitme.dev:3000"