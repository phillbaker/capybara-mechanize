require 'capybara'

module Capybara::Mechanize
  class << self

    # Host that should be considered local (includes default_host)
    def local_hosts
      @local_hosts ||= begin
        default_host = URI.parse(Capybara.default_host || "").host || Capybara.default_host
        [default_host].compact
      end
    end
    
    def local_hosts=(hosts)
      @local_hosts = hosts
    end
  end
end

require 'capybara/mechanize/driver'

Capybara.register_driver :mechanize do |app|
  Capybara::Mechanize::Driver.new(app)
end