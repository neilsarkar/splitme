ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require 'capybara/rails'
require 'capybara/rspec'
require "pry"
require 'webmock/rspec'

require 'factory_girl_rails'
require 'email_spec'

alias running proc

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each {|f| require_relative f}

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.before :suite do
    Capybara.default_driver = :chrome
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
end
