require 'spec_helper'

describe Capybara::Driver::Mechanize do
  before(:each) do
    Capybara.app_host = "http://capybara-testapp.heroku.com"
  end
  
  after(:each) do
    Capybara.app_host = nil
  end

  before do
    @driver = Capybara::Driver::Mechanize.new(TestApp)
  end

  context "in remote mode" do
    it_should_behave_like "driver"
    it_should_behave_like "driver with header support"
    it_should_behave_like "driver with status code support"
    it_should_behave_like "driver with cookies support"
  
    # Pending:
    # it_should_behave_like "driver with infinite redirect detection"
  end
end