# frozen_string_literal: true

require 'capybara/mechanize'

Before('@mechanize') do
  Capybara.current_driver = :mechanize
end
