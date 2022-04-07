# frozen_string_literal: true

require 'spec_helper'

module TestSessions
  RemoteMechanize = Capybara::Session.new(:mechanize, TestApp)
end

shared_context 'remote tests' do
  before do
    Capybara.app_host = remote_test_url
  end

  after do
    Capybara.app_host = nil
  end
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

Capybara::SpecHelper.run_specs(TestSessions::RemoteMechanize, 'RemoteMechanize', capybara_skip: skipped_tests) do |example|
  case example.metadata[:full_description]
  when /has_css\? should support case insensitive :class and :id options/
    skip "Nokogiri doesn't support case insensitive CSS attribute matchers"
  end
end

describe Capybara::Session do
  context 'with remote mechanize driver' do
    include_context 'remote tests'

    let(:session) { Capybara::Session.new(:mechanize, ExtendedTestApp) }

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

    context 'remote app in a sub-path' do
      it 'follows relative link correctly' do
        session.visit '/subsite/relative_link_to_host'
        session.click_link 'host'
        expect(session.body).to include('request_info2/host')
      end

      it 'follows local link correctly' do
        session.visit '/subsite/local_link_to_host'
        session.click_link 'host'
        expect(session.body).to include('request_info2/host')
      end
    end
  end
end
