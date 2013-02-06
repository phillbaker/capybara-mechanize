require 'spec_helper'

describe Capybara::Mechanize::Driver, 'remote' do
  before do
    Capybara.app_host = REMOTE_TEST_URL
  end

  after do
    Capybara.app_host = nil
  end

  let(:driver) { Capybara::Mechanize::Driver.new(ExtendedTestApp) }

  context "in remote mode" do
    it "should pass arguments through to a get request" do
      driver.visit("#{REMOTE_TEST_URL}/form/get", {:form => "success"})
      driver.html.should include('success')
    end

    it "should pass arguments through to a post request" do
      driver.post("#{REMOTE_TEST_URL}/form", {:form => "success"})
      driver.html.should include('success')
    end

    describe "redirect" do
      it "should handle redirects with http-params" do
        driver.visit "#{REMOTE_TEST_URL}/redirect_with_http_param"
        driver.html.should include('correct redirect')
      end
    end

    context "for a post request" do
      it 'transforms nested map in post data' do
        driver.post("#{REMOTE_TEST_URL}/form", {:form => {:key => 'value'}})
        driver.html.should include(':key=>"value"')
      end
    end

    context 'process remote request' do
      it 'transforms nested map in post data' do
        driver.submit(:post, "#{REMOTE_TEST_URL}/form", {:form => {:key => 'value'}})
        driver.html.should include(':key=>"value"')
      end
    end
  end
end
