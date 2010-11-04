require 'spec_helper'

describe "Capybara::Driver::Mechanize, in local model" do
  before do
    @driver = Capybara::Driver::Mechanize.new(ExtendedTestApp)
  end
  
  it "should throw an error when no rack app is given without an app host" do
    running do
      Capybara::Driver::Mechanize.new
    end.should raise_error(ArgumentError, "You have to set at least Capybara.app_host or Capybara.app")
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
      @driver.should be_remote('http://www.remote.com')
    end
  end
  
  context "with a default url, no app host" do
    before :each do
      Capybara.default_host = 'www.local.com'
    end
    
    it "should treat urls with the same host names as local" do
      @driver.should_not be_remote('http://www.local.com')
    end
    
    it "should treat other urls as remote" do
      @driver.should be_remote('http://www.remote.com')
    end
    
    it "should treat relative paths as remote if the previous request was remote" do
      @driver.visit(REMOTE_TEST_URL)
      @driver.should be_remote('/some_relative_link')
    end

    it "should treat relative paths as local if the previous request was local" do
      @driver.visit('http://www.local.com')
      @driver.should_not be_remote('/some_relative_link')
    end

    it "should receive the right host" do
      @driver.visit('http://www.local.com/host')
      @driver.body.should == "current host is www.local.com:80, method get"
    end

    it "should always switch to the right context" do
      @driver.visit('http://www.local.com/host')
      should_be_a_local_get

      @driver.visit('/host')
      should_be_a_local_get
      @driver.should_not be_remote('/first_local')

      @driver.visit("#{REMOTE_TEST_URL}/host")
      should_be_a_remote_get
      @driver.should be_remote('/first_remote')

      @driver.visit('/host')
      should_be_a_remote_get
      @driver.should be_remote('/second_remote')

      @driver.visit('http://www.local.com/host')
      should_be_a_local_get
      @driver.should_not be_remote('/second_local')
    end

    it "should follow redirects from local to remote" do
      @driver.visit("http://www.local.com/redirect_to/#{REMOTE_TEST_URL}/host")
      should_be_a_remote_get
    end
    
    after :each do
      Capybara.default_host = nil
    end
  end

  it "should include the right host when remote" do
    @driver.visit("#{REMOTE_TEST_URL}/host")
    should_be_a_remote_get
  end

  it "should follow redirects from remote to local" do
    @driver.visit("#{REMOTE_TEST_URL}/redirect_to/http://www.local.com/host")
    should_be_a_local_get
  end

  def should_be_a_remote_get
    @driver.body.should == "current host is #{REMOTE_TEST_HOST}, method get"
  end
  
  def should_be_a_local_get
    @driver.body.should == "current host is www.local.com:80, method get"
  end

end
