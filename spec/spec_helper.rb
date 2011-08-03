require 'bundler/setup'
require 'capybara'
require 'capybara/mechanize'
require 'artifice'

require 'sinatra'

require 'capybara/spec/extended_test_app'

# TODO move this stuff into capybara
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

RSpec.configure do |config|
  config.before(:all) do
    Artifice.activate_with(ExtendedTestApp)
  end

  config.after do
    Capybara.default_selector = :xpath
    Capybara::Mechanize.local_hosts = nil
  end

  config.after(:all) do
    Artifice.deactivate
  end
  # config.filter_run :focus => true
end

REMOTE_TEST_URL = "http://localhost"
