require 'spec_helper'

describe "Capybara::Driver::Mechanize, in local model" do
  before do
    @driver = Capybara::Driver::Mechanize.new(ExtendedTestApp)
  end
  
  it "should throw an error when no rack app is given" do
    running do
      Capybara::Driver::Mechanize.new(nil)
    end.should raise_error(ArgumentError)
  end
  
  it_should_behave_like "driver"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
  it_should_behave_like "driver with infinite redirect detection"

  it "should default to local mode" do
    @driver.remote?('http://www.local.com').should be false
  end
  
  context "with an app_host" do
    
    before do
      Capybara.app_host = 'remote.com'
    end
    
    after do
      Capybara.app_host = nil
    end

    it "should treat urls as remote" do
      @driver.remote?('http://www.remote.com').should be true
    end
  end
  
  context "with a default url, no app host" do
    before :each do
      Capybara.default_host = 'local.com'
    end
    
    it "should treat urls with the same host names as local" do
      @driver.remote?('http://www.local.com').should be false
    end
    
    it "should treat other urls as remote" do
      @driver.remote?('http://www.remote.com').should be true
    end

    it "should receive the right host" do
      @driver.visit('http://www.local.com/host')
      @driver.body.should include('local.com')
    end

    it "should follow redirects from local to remote" do
      @driver.visit("http://www.local.com/redirect_to/#{REMOTE_TEST_URL}/host")
      @driver.body.should include(REMOTE_TEST_HOST)
    end
    
    after :each do
      Capybara.default_host = nil
    end
  end

  it "should include the right host when remote" do
    @driver.visit("#{REMOTE_TEST_URL}/host")
    @driver.body.should include(REMOTE_TEST_HOST)
  end

  
  it "should follow redirects from remote to local" do
    @driver.visit("#{REMOTE_TEST_URL}/redirect_to/http://www.local.com/host")
    @driver.body.should include('local.com')
  end

end
