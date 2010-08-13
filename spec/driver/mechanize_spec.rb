require 'spec_helper'

describe Capybara::Driver::Mechanize do
  before do
    @driver = Capybara::Driver::Mechanize.new(TestApp)
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

  # Pending:
  # it_should_behave_like "driver with infinite redirect detection"


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
    
    after :each do
      Capybara.default_host = nil
    end
  end

end
