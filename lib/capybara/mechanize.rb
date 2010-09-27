module Capybara
  module Driver
    autoload :Mechanize, 'capybara/driver/mechanize_driver'
  end
end

Capybara.register_driver :mechanize do |app|
  Capybara::Driver::Mechanize.new(app)
end