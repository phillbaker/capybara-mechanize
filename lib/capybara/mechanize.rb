# frozen_string_literal: true

require 'capybara'

module Capybara::Mechanize
  class << self
    # Host that should be considered local (includes default_host)
    def local_hosts
      @local_hosts ||= begin
        default_host = URI.parse(Capybara.default_host || '').host || Capybara.default_host
        [default_host].compact
      end
    end

    attr_writer :local_hosts
  end
end

require 'capybara/mechanize/driver'

Capybara.register_driver :mechanize do |app|
  Capybara::Mechanize::Driver.new(app)
end
