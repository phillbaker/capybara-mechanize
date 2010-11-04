require 'spec_helper'

describe Capybara::Driver::Mechanize do
  before(:each) do
    Capybara.app_host = REMOTE_TEST_URL
  end
  
  after(:each) do
    Capybara.app_host = nil
  end

  before do
    @driver = Capybara::Driver::Mechanize.new
  end
  
  context "in remote mode" do
    it "should not throw an error when no rack app is given" do
      running do
        Capybara::Driver::Mechanize.new
      end.should_not raise_error(ArgumentError)
    end
    
    it "should pass arguments through to a get request" do
      @driver.visit("#{REMOTE_TEST_URL}/form/get", {:form => "success"})
      @driver.body.should == %{<pre id="results">--- success\n</pre>}
    end

    it_should_behave_like "driver"
    it_should_behave_like "driver with header support"
    it_should_behave_like "driver with status code support"
    it_should_behave_like "driver with cookies support"
    it_should_behave_like "driver with infinite redirect detection"
  end
  
end