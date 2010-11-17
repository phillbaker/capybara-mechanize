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
# 127.0.0.1 capybara-testapp.heroku.com to your host file
# Run the app with the following line: 
# ruby -rrubygems lib/capybara/spec/extended_test_app.rb
REMOTE_TEST_HOST = "capybara-testapp.heroku.com:8070"
LOCAL_TEST_HOST  = "localhost:8070"
REMOTE_TEST_URL  = "http://#{REMOTE_TEST_HOST}"
LOCAL_TEST_URL   = "http://#{LOCAL_TEST_HOST}"
