# frozen_string_literal: true

require 'spec_helper'

module TestSessions
  Mechanize = Capybara::Session.new(:mechanize, TestApp)
end

skipped_tests = %i[
  about_scheme
  active_element
  css
  download
  frames
  hover
  html_validation
  js
  modals
  screenshot
  scroll
  send_keys
  server
  shadow_dom
  spatial
  windows
]

Capybara::SpecHelper.run_specs(TestSessions::Mechanize, 'Mechanize', capybara_skip: skipped_tests) do |example|
  case example.metadata[:full_description]
  when /has_css\? should support case insensitive :class and :id options/
    skip "Nokogiri doesn't support case insensitive CSS attribute matchers"
  end
end

describe Capybara::Session do
  context 'with mechanize driver' do
    let(:session) { Capybara::Session.new(:mechanize, ExtendedTestApp) }

    before do
      Capybara.default_host = 'http://www.local.com'
    end

    after do
      Capybara.default_host = CAPYBARA_DEFAULT_HOST
    end

    describe '#driver' do
      it 'should be a mechanize driver' do
        expect(session.driver).to be_an_instance_of(Capybara::Mechanize::Driver)
      end
    end

    describe '#mode' do
      it 'should remember the mode' do
        expect(session.mode).to eq(:mechanize)
      end
    end

    describe '#click_link' do
      it 'should use data-method if option is true' do
        session.driver.options[:respect_data_method] = true
        session.visit '/with_html'
        session.click_link 'A link with data-method'
        expect(session.html).to include('The requested object was deleted')
      end

      it 'should not use data-method if option is false' do
        session.driver.options[:respect_data_method] = false
        session.visit '/with_html'
        session.click_link 'A link with data-method'
        expect(session.html).to include('Not deleted')
      end

      it "should use data-method if available even if it's capitalized" do
        session.driver.options[:respect_data_method] = true
        session.visit '/with_html'
        session.click_link 'A link with capitalized data-method'
        expect(session.html).to include('The requested object was deleted')
      end

      after do
        session.driver.options[:respect_data_method] = false
      end
    end

    describe '#attach_file' do
      context 'with multipart form' do
        it 'should submit an empty form-data section if no file is submitted' do
          session.visit('/form')
          session.click_button('Upload Empty')
          expect(session.html).to include('Successfully ignored empty file field.')
        end
      end
    end

    it 'should use the last remote url when following relative links' do
      session.visit("#{remote_test_url}/relative_link_to_host")
      session.click_link 'host'
      expect(session.body).to include("Current host is #{remote_test_url}/request_info/host, method get")
    end

    it 'should use the last remote url when submitting a form with a relative action' do
      session.visit("#{remote_test_url}/form_with_relative_action_to_host")
      session.click_button 'submit'
      expect(session.body).to include("Current host is #{remote_test_url}/request_info/host, method post")
    end

    it 'should use the last url when submitting a form with no action' do
      session.visit("#{remote_test_url}/request_info/form_with_no_action")
      session.click_button 'submit'
      expect(session.body).to include("Current host is #{remote_test_url}/request_info/form_with_no_action, method post")
    end

    it 'should send correct user agent' do
      session.visit("#{remote_test_url}/request_info/user_agent")
      expect(session.body).to include('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.853.0 Safari/535.2')
    end

    context 'form referer when switching from local to remote' do
      it 'sends the referer' do
        session.visit "/form_posts_to/#{remote_test_url}/get_referer"
        session.click_button 'submit'
        expect(session.body).to include 'Got referer'
      end
    end
  end
end
