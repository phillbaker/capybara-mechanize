require 'capybara'
require 'capybara/mechanize'

require 'sinatra'
require 'spec'

# TODO move this stuff into capybara
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

Spec::Runner.configure do |config|
  config.after do
    Capybara.default_selector = :xpath
  end
end