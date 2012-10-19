window.SM ?= {}

window.config = {}
window.config.host = window.location.href.match("(https?:\/\/.*?)(\/|$)")[1]
window.config.urls = {}

if window.config.host.match("splitmeapp.com")
  window.config.env = "production"
else if window.config.host.match("splitme-b")
  window.config.env = "staging"
else if window.config.host.match("splitme.dev")
  window.config.env = "development"
else if window.config.host.match("127.0.0.1")
  window.config.env = "test"

if window.config.env == "production"
  window.config.urls.api = "https://www.splitmeapp.com/api"
  balanced.init("/v1/marketplaces/MP3Cm5EGcLGKWXDNsMvn8RvQ")
else if window.config.env == "staging"
  window.config.urls.api = "https://splitme-b.herokuapp.com/api"
  balanced.init("/v1/marketplaces/TEST-MP3iOVTNMVX7lg0SG16NQV2v")
else if window.config.env == "development"
  window.config.urls.api = "http://splitme.dev:3000/api"
  balanced.init("/v1/marketplaces/TEST-MP428UdVEvy6F1lLztbdA99d")
else if window.config.env == "test"
  port = window.config.host.match(/:(\d+)$/)[1]
  window.balanced = new BalancedStub
  window.config.urls.api = "http://splitme.dev:#{port}/api"
