require 'spec_helper'

describe "Capybara::Driver::Mechanize, in local model" do
  before do
    @driver = Capybara::Mechanize::Driver.new(ExtendedTestApp)
  end
  
  it "should throw an error when no rack app is given without an app host" do
    running do
      Capybara::Mechanize::Driver.new
    end.should raise_error(ArgumentError, "You have to set at least Capybara.app_host or Capybara.app")
  end
  
  it_should_behave_like "driver"
  it_should_behave_like "driver with header support"
  it_should_behave_like "driver with status code support"
  it_should_behave_like "driver with cookies support"
  it_should_behave_like "driver with infinite redirect detection"

  it "should default to local mode for relative paths" do
    @driver.should_not be_remote('/')
  end
  
  it "should default to local mode for the default host" do
    @driver.should_not be_remote('http://www.example.com')
  end

  context "with an app_host" do
  
    before do
      Capybara.app_host = 'http://www.remote.com'
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
      Capybara.default_host = 'http://www.local.com'
    end
  
    it "should treat urls with the same host names as local" do
      @driver.should_not be_remote('http://www.local.com')
    end
  
    it "should treat other urls as remote" do
      @driver.should be_remote('http://www.remote.com')
    end
  
    it "should treat relative paths as remote if the previous request was remote", :focus => true do
      @driver.visit(REMOTE_TEST_URL)
      @driver.should be_remote('/some_relative_link')
    end

    it "should treat relative paths as local if the previous request was local" do
      @driver.visit('http://www.local.com')
      @driver.should_not be_remote('/some_relative_link')
    end

    it "should receive the right host" do
      @driver.visit('http://www.local.com/host')
      should_be_a_local_get
    end

    it "should consider relative paths to be local when the previous request was local" do
      @driver.visit('http://www.local.com/host')
      @driver.visit('/host')

      should_be_a_local_get
      @driver.should_not be_remote('/first_local')
    end
    
    it "should consider relative paths to be remote when the previous request was remote", :focus => true do
      @driver.visit("#{REMOTE_TEST_URL}/host")
      @driver.get('/host')

      should_be_a_remote_get
      @driver.should be_remote('/second_remote')
    end
    
    it "should always switch to the right context" do#, :focus => true do
      @driver.visit('http://www.local.com/host')
      @driver.get('/host')
      @driver.get("#{REMOTE_TEST_URL}/host")
      @driver.get('/host')
      @driver.get('http://www.local.com/host')

      should_be_a_local_get
      @driver.should_not be_remote('/second_local')
    end

    it "should follow redirects from local to remote" do
      @driver.visit("http://www.local.com/redirect_to/#{REMOTE_TEST_URL}/host")
      should_be_a_remote_get
    end
    
    it "should follow redirects from remote to local", :focus => true do
      @driver.visit("#{REMOTE_TEST_URL}/redirect_to/http://www.local.com/host")
      should_be_a_local_get
    end
  
    after :each do
      Capybara.default_host = nil
    end
  end

  it "should include the right host when remote" do
    @driver.visit("#{REMOTE_TEST_URL}/host")
    should_be_a_remote_get
  end

  describe '#reset!' do
    before :each do
      Capybara.default_host = 'http://www.local.com'
    end

    it 'should reset remote host' do
      @driver.visit("#{REMOTE_TEST_URL}/host")
      should_be_a_remote_get
      @driver.reset!
      @driver.visit("/host")
      should_be_a_local_get
    end
  end

  def should_be_a_remote_get
    @driver.body.should include(REMOTE_TEST_URL)
  end
  
  def should_be_a_local_get
    @driver.body.should include("www.local.com")
  end

end
