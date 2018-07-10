require 'spec_helper'

describe Capybara::Mechanize::Driver, 'remote' do
  before do
    Capybara.app_host = remote_test_url
  end

  after do
    Capybara.app_host = nil
  end

  let(:driver) { Capybara::Mechanize::Driver.new(ExtendedTestApp) }

  context "in remote mode" do
    it "should pass arguments through to a get request" do
      driver.visit("#{remote_test_url}/form/get", {:form => {:value => "success"}})
      driver.html.should include('success')
    end

    it "should pass arguments through to a post request" do
      driver.post("#{remote_test_url}/form", {:form => {:value => "success"}})
      driver.html.should include('success')
    end

    describe "redirect" do
      it "should handle redirects with http-params" do
        driver.visit "#{remote_test_url}/redirect_with_http_param"
        driver.html.should include('correct redirect')
      end
    end

    context "for a post request" do
      it 'transforms nested map in post data' do
        driver.post("#{remote_test_url}/form", {:form => {:key => 'value'}})
        driver.html.should match(/:key=>"value"|key: value/)
      end
    end

    context 'process remote request' do
      it 'transforms nested map in post data' do
        driver.submit(:post, "#{remote_test_url}/form", {:form => {:key => 'value'}})
        driver.html.should match(/:key=>"value"|key: value/)
      end
    end
  end
end
