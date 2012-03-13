require 'bundler/setup'
require 'capybara'
require 'capybara/dsl'
require 'capybara/mechanize'
require 'capybara/spec/extended_test_app'

require 'sinatra'

# TODO move this stuff into capybara
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster
Capybara.app = ExtendedTestApp

rack_server = Capybara::Server.new(Capybara.app)
rack_server.boot

RSpec.configure do |config|
  config.after do
    Capybara.default_selector = :xpath
    Capybara::Mechanize.local_hosts = nil
  end
  # config.filter_run :focus => true
end

REMOTE_TEST_URL = "http://localhost:#{rack_server.port}"
