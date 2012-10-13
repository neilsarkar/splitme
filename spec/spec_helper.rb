ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require 'capybara/rails'
require 'capybara/rspec'
require "pry"

alias running proc

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each {|f| require_relative f}

RSpec.configure do |config|
  config.before :suite do
    Capybara.default_driver = :chrome
  end

  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
end
