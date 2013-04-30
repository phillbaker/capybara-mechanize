require 'spec_helper'

describe Capybara::Mechanize::Driver, 'local' do
  let(:driver) { Capybara::Mechanize::Driver.new(ExtendedTestApp) }

  describe ':headers option' do
    it 'should always set headers' do
      driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      driver.visit('/get_header')
      driver.html.should include('foobar')
    end

    it 'should keep headers on link clicks' do
      driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      driver.visit('/header_links')
      driver.find_xpath('.//a').first.click
      driver.html.should include('foobar')
    end

    it 'should keep headers on form submit' do
      driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      driver.visit('/header_links')
      driver.find_xpath('.//input').first.click
      driver.html.should include('foobar')
    end

    it 'should keep headers on redirects' do
      driver = Capybara::RackTest::Driver.new(TestApp, :headers => {'HTTP_FOO' => 'foobar'})
      driver.visit('/get_header_via_redirect')
      driver.html.should include('foobar')
    end
  end

  describe ':follow_redirects option' do
    it "defaults to following redirects" do
      driver = Capybara::RackTest::Driver.new(TestApp)

      driver.visit('/redirect')
      driver.response.header['Location'].should be_nil
      driver.browser.current_url.should match %r{/landed$}
    end

    it "is possible to not follow redirects" do
      driver = Capybara::RackTest::Driver.new(TestApp, :follow_redirects => false)

      driver.visit('/redirect')
      driver.response.header['Location'].should match %r{/redirect_again$}
      driver.browser.current_url.should match %r{/redirect$}
    end
  end

  describe ':redirect_limit option' do
    context "with default redirect limit" do
      let(:driver) { Capybara::RackTest::Driver.new(TestApp) }

      it "should follow 5 redirects" do
        driver.visit("/redirect/5/times")
        driver.html.should include('redirection complete')
      end

      it "should not follow more than 6 redirects" do
        expect do
          driver.visit("/redirect/6/times")
        end.to raise_error(Capybara::InfiniteRedirectError)
      end
    end

    context "with 21 redirect limit" do
      let(:driver) { Capybara::RackTest::Driver.new(TestApp, :redirect_limit => 21) }

      it "should follow 21 redirects" do
        driver.visit("/redirect/21/times")
        driver.html.should include('redirection complete')
      end

      it "should not follow more than 21 redirects" do
        expect do
          driver.visit("/redirect/22/times")
        end.to raise_error(Capybara::InfiniteRedirectError)
      end
    end
  end

  it "should default to local mode for relative paths" do
    driver.should_not be_remote('/')
  end

  it "should default to local mode for the default host" do
    driver.should_not be_remote('http://www.example.com')
  end

  context "with an app_host" do

    before do
      Capybara.app_host = 'http://www.remote.com'
    end

    after do
      Capybara.app_host = nil
    end

    it "should treat urls as remote" do
      driver.should be_remote('http://www.remote.com')
    end
  end

  context "with a default url, no app host" do
    before do
      Capybara.default_host = 'www.local.com'
    end

    it "should allow local hosts to be set" do
      Capybara::Mechanize.local_hosts = ['subdomain.local.com']
      driver.should_not be_remote('http://subdomain.local.com')
    end

    it "should treat urls with the same host names as local" do
      driver.should_not be_remote('http://www.local.com')
    end

    it "should treat other urls as remote" do
      driver.should be_remote('http://www.remote.com')
    end

    it "should treat relative paths as remote if the previous request was remote" do
      driver.visit(REMOTE_TEST_URL)
      driver.should be_remote('/some_relative_link')
    end

    it "should treat relative paths as local if the previous request was local" do
      driver.visit('http://www.local.com')
      driver.should_not be_remote('/some_relative_link')
    end

    it "should receive the right host" do
      driver.visit('http://www.local.com/host')
      should_be_a_local_get
    end

    it "should consider relative paths to be local when the previous request was local" do
      driver.visit('http://www.local.com/host')
      driver.visit('/host')

      should_be_a_local_get
      driver.should_not be_remote('/first_local')
    end

    it "should consider relative paths to be remote when the previous request was remote" do
      driver.visit("#{REMOTE_TEST_URL}/host")
      driver.get('/host')

      should_be_a_remote_get
      driver.should be_remote('/second_remote')
    end

    it "should always switch to the right context" do
      driver.visit('http://www.local.com/host')
      driver.get('/host')
      driver.get("#{REMOTE_TEST_URL}/host")
      driver.get('/host')
      driver.get('http://www.local.com/host')

      should_be_a_local_get
      driver.should_not be_remote('/second_local')
    end

    it "should follow redirects from local to remote" do
      driver.visit("http://www.local.com/redirect_to/#{REMOTE_TEST_URL}/host")
      should_be_a_remote_get
    end

    it "should follow redirects from remote to local" do
      driver.visit("#{REMOTE_TEST_URL}/redirect_to/http://www.local.com/host")
      should_be_a_local_get
    end

    after do
      Capybara.default_host = nil
    end

    it "should raise a useful error for sites that return a 404, because it is probably a misconfiguration" do
      expect { 
        driver.visit("http://iamreallysurethatthisdoesntexist.com/canttouchthis")
      }.to raise_error(%r{Received the following error for a GET request to http://iamreallysurethatthisdoesntexist.com/canttouchthis:})
    end
  end

  it "should include the right host when remote" do
    driver.visit("#{REMOTE_TEST_URL}/host")
    should_be_a_remote_get
  end

  describe '#reset!' do
    before do
      Capybara.default_host = 'http://www.local.com'
    end

    it 'should reset remote host' do
      driver.visit("#{REMOTE_TEST_URL}/host")
      should_be_a_remote_get
      driver.reset!
      driver.visit("/host")
      should_be_a_local_get
    end
  end

  def should_be_a_remote_get
    driver.current_url.should include(REMOTE_TEST_URL)
  end

  def should_be_a_local_get
    driver.current_url.should include("www.local.com")
  end
# 
end
