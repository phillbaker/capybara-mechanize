require "rspec"
require 'capybara'
require 'capybara/mechanize/browser'
require File.expand_path('../spec_helper.rb', __FILE__)

describe_internally Capybara::Mechanize::Browser do
  describe "Resolving Relative URLs" do

    before(:all) do
      @original_app_host = Capybara.app_host
      @driver = Object.new
      @browser = Capybara::Mechanize::Browser.new(@driver)
    end

    after(:all) do
      Capybara.app_host = @original_app_host
      @browser.reset_host!
    end

    context "resolving on 'http://localhost'" do
      before(:all) do
        Capybara.app_host ='http://localhost'
      end

      it "resolves '/'" do
        @browser.resolve_relative_url('/').to_s.should == 'http://localhost/'
      end

      it "resolves '/home'" do
        @browser.resolve_relative_url('/home').to_s.should == 'http://localhost/home'
      end

      it "resolves 'home'" do
        @browser.resolve_relative_url('home').to_s.should == 'http://localhost/home'
      end

      it "resolves 'user/login'" do
        @browser.resolve_relative_url('user/login').to_s.should == 'http://localhost/user/login'
      end
    end

    context "resolving on 'http://localhost/subsite'" do
      before() do
        Capybara.app_host='http://localhost/subsite'
      end

      it "resolves '/'" do
        @browser.resolve_relative_url('/').to_s.should == 'http://localhost/subsite/'
      end

      it "resolves '/home'" do
        @browser.resolve_relative_url('/home').to_s.should == 'http://localhost/subsite/home'
      end

      it "resolves 'home'" do
        @browser.resolve_relative_url('home').to_s.should == 'http://localhost/subsite/home'
      end

      it "resolves 'user/login'" do
        @browser.resolve_relative_url('user/login').to_s.should == 'http://localhost/subsite/user/login'
      end

      it "resolves '/subsite/user/login'" do
        @browser.resolve_relative_url('/subsite/user/login').to_s.should == 'http://localhost/subsite/user/login'
      end
    end
  end
end
