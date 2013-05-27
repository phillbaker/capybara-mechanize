require 'capybara/spec/spec_helper'
require 'capybara/mechanize'
require 'capybara/spec/extended_test_app'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

RSpec.configure do |config|
  # This needs to remain commented out until there is a capybara release that includes https://github.com/jnicklas/capybara/pull/1078
  # config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Used with DisableExternalTests
  config.filter_run_excluding :external_test_disabled

  config.after do
    Capybara::Mechanize.local_hosts = nil
  end

  Capybara::SpecHelper.configure(config)
end

setup = ExtendedTestAppSetup.new.boot
REMOTE_TEST_URL = setup.remote_test_url
