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

class Net::HTTP::Persistent
  # Mechanize 2.1 started using the net-http-persistent gem to support persistent (much faster)
  # HTTP connections.  The gem has method to switch between either using Net::HTTP or
  # Net::HTTP::Persistent::SSLReuse.
  #
  # Net::HTTP::Persistent::SSLReuse is not overwritten by the Artifice gem.
  #
  # This rewrite of Net::HTTP::Persistent rewrites a the method inside:
  #
  #     /net-http-persistent/lib/net/http/persistent.rb
  #
  def http_class # :nodoc:
    Net::HTTP
  end
end

REMOTE_TEST_URL = "http://localhost"
