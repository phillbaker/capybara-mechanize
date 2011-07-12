require 'bundler/setup'
require 'capybara'
require 'capybara/mechanize'

require 'sinatra'

require 'capybara/spec/extended_test_app'

# TODO move this stuff into capybara
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

RSpec.configure do |config|
  config.after do
    Capybara.default_selector = :xpath
  end
  # config.filter_run :focus => true
end

# Until this library is merged with capybara there needs to be a local app and you need to add
# Install pow (get.pow.cx) and run add a symlink in ~/.pow with ln -s lib/capybara/spec capybara-testapp.heroku
REMOTE_TEST_URL = "http://capybara-testapp.heroku.dev:80"
