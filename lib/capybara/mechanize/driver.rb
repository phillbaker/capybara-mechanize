require 'capybara/mechanize/browser'

class Capybara::Mechanize::Driver < Capybara::RackTest::Driver
  
  def initialize(app, options = {})
    raise ArgumentError, "mechanize requires a rack application, but none was given" unless app

    super
  end

  def remote?(url)
    browser.remote?(url)
  end
  
  def browser
    @browser ||= Capybara::Mechanize::Browser.new(self)
  end
  
end
