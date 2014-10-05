# This class works around some weirdness with Capybara's test suite and sinatra's behavior.
# We need to make sure that sinatra uses TestApp for at least one request before the Capybara session
# specs run.  Without this we get errors from sinatra trying to handle requests with TestApp.clone
class ExtendedTestAppSetup
  include Capybara::DSL

  attr_reader :remote_test_url

  def boot
    boot_test_app
    boot_remote_app
    Capybara.raise_server_errors = false

    self
  end

  def boot_test_app
    Capybara.app = TestApp
    dummy_server = Capybara::Server.new(TestApp)
    dummy_server.boot

    # Boot TestApp's Sinatra
    visit '/'
  end

  def boot_remote_app
    remote_server = Capybara::Server.new(ExtendedTestApp)
    remote_server.boot
    @remote_test_url = "http://localhost:#{remote_server.port}"
  end
end
