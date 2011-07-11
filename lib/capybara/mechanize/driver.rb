require 'capybara/mechanize/browser'

class Capybara::Mechanize::Driver < Capybara::RackTest::Driver
  
  def initialize(app = nil, options = {})
    if !app && !Capybara.app_host
      raise ArgumentError, "You have to set at least Capybara.app_host or Capybara.app"
    end

    @app, @options = app, options
  end

  def remote?(url)
    browser.remote?(url)
  end
  
  def browser
    @browser ||= Capybara::Mechanize::Browser.new(app, options)
  end
  
end
