require 'capybara/spec/spec_helper'
require 'capybara/mechanize'
require 'capybara/spec/extended_test_app'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

RSpec.configure do |config|
  config.filter_run :focus => true unless ENV['CI']
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true if RSpec::Version::STRING =~ /^2\./

  # Used with DisableExternalTests
  config.filter_run_excluding :external_test_disabled

  config.include RemoteTestUrl
  config.extend RemoteTestUrl
  config.include Capybara::SpecHelper

  config.after do
    Capybara::Mechanize.local_hosts = nil
  end

  Capybara::SpecHelper.configure(config)

  config.order = "random"

  CAPYBARA_DEFAULT_HOST = Capybara.default_host
end

