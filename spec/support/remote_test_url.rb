# frozen_string_literal: true

module RemoteTestUrl
  def remote_test_url
    ExtendedTestAppSetup.new.boot.remote_test_url
  end
end
