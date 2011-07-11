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

module TestHelpers
  def body_with_content(body)
    %{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">\n<html><body>#{body}</body></html>\n}
  end
  
  def body_with_paragraph(content)
    body_with_content "<p>#{content}</p>"
  end
  
  def body_with_expected_host(expected_host)
    body_with_paragraph "current host is #{expected_host}, method get"
  end
end

RSpec.configure do |config|
  config.include TestHelpers

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
REMOTE_TEST_URL = "http://#{REMOTE_TEST_HOST}"
