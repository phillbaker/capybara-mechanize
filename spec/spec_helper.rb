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



# for testing private methods, courtesy of
# http://kailuowang.blogspot.com.au/2010/08/testing-private-methods-in-rspec.html
def describe_internally *args, &block
  example = describe *args, &block
  klass = args[0]
  if klass.is_a? Class
    saved_private_instance_methods = klass.private_instance_methods
    example.before do
      klass.class_eval { public *saved_private_instance_methods }
    end
    example.after do
      klass.class_eval { private *saved_private_instance_methods }
    end
  end
end
