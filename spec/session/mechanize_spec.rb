require 'spec_helper'

describe Capybara::Session do
  context 'with mechanize driver' do
    before do
      @session = Capybara::Session.new(:mechanize, TestApp)
      @session.driver.options[:respect_data_method] = true
      Capybara.default_host = 'http://www.local.com'
    end

    describe '#driver' do
      it "should be a mechanize driver" do
        @session.driver.should be_an_instance_of(Capybara::Mechanize::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :mechanize
      end
    end

    describe '#click_link' do
      it "should use data-method if available" do
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        @session.body.should include('The requested object was deleted')
      end
    end

    it "should use the last remote url when following relative links" do
      @session.visit("#{REMOTE_TEST_URL}/relative_link_to_host")
      @session.click_link "host"
      @session.body.should include("Current host is #{REMOTE_TEST_URL}/request_info/host, method get")
    end

    it "should use the last remote url when submitting a form with a relative action" do
      @session.visit("#{REMOTE_TEST_URL}/form_with_relative_action_to_host")
      @session.click_button "submit"
      @session.body.should include("Current host is #{REMOTE_TEST_URL}/request_info/host, method post")
    end

    it "should use the last url when submitting a form with no action" do
      @session.visit("#{REMOTE_TEST_URL}/request_info/form_with_no_action")
      @session.click_button "submit"
      @session.body.should include("Current host is #{REMOTE_TEST_URL}/request_info/form_with_no_action, method post")
    end

    it "should send correct user agent" do
      @session.visit("#{REMOTE_TEST_URL}/request_info/user_agent")
      @session.body.should include("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.853.0 Safari/535.2")
    end

    it_should_behave_like "session"
    it_should_behave_like "session without javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"
  end
end
