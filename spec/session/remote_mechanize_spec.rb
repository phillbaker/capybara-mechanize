require 'spec_helper'

module TestSessions
  Mechanize = Capybara::Session.new(:mechanize, TestApp)
end

shared_context "remote tests" do
  before do
    Capybara.app_host = remote_test_url
  end

  after do
    Capybara.app_host = nil
  end
end

session_describe = Capybara::SpecHelper.run_specs TestSessions::Mechanize, "Mechanize", :capybara_skip => [
  :js,
  :screenshot,
  :frames,
  :windows,
  :server,
  :hover,
  :modals,
  :about_scheme,
  :send_keys,
  :css,
  :download
]

session_describe.include_context("remote tests")

# We disable additional tests because we don't provide a server, but do test external URls
disabler = DisableExternalTests.new
disabler.tests_to_disable = [
  ['#visit', 'when Capybara.always_include_port is true', 'should fetch a response from the driver with an absolute url without a port'],
  ['#has_current_path?', 'should compare the full url if url: true is used'],
  ['#reset_session!', 'raises any errors caught inside the server'],
  ['#reset_session!', 'raises any standard errors caught inside the server']
]
disabler.disable(session_describe)

describe Capybara::Session do
  context 'with remote mechanize driver' do
    include_context 'remote tests'

    let(:session) { Capybara::Session.new(:mechanize, ExtendedTestApp) }

    describe '#driver' do
      it "should be a mechanize driver" do
        session.driver.should be_an_instance_of(Capybara::Mechanize::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        session.mode.should == :mechanize
      end
    end

    describe '#click_link' do
      it "should use data-method if option is true" do
        session.driver.options[:respect_data_method] = true
        session.visit "/with_html"
        session.click_link "A link with data-method"
        session.html.should include('The requested object was deleted')
      end

      it "should not use data-method if option is false" do
        session.driver.options[:respect_data_method] = false
        session.visit "/with_html"
        session.click_link "A link with data-method"
        session.html.should include('Not deleted')
      end

      it "should use data-method if available even if it's capitalized" do
        session.driver.options[:respect_data_method] = true
        session.visit "/with_html"
        session.click_link "A link with capitalized data-method"
        session.html.should include('The requested object was deleted')
      end

      after do
        session.driver.options[:respect_data_method] = false
      end
    end

    describe "#attach_file" do
      context "with multipart form" do
        it "should submit an empty form-data section if no file is submitted" do
          session.visit("/form")
          session.click_button("Upload Empty")
          session.html.should include('Successfully ignored empty file field.')
        end
      end
    end

    context "remote app in a sub-path" do
      it "follows relative link correctly" do
        session.visit "/subsite/relative_link_to_host"
        session.click_link "host"
        session.body.should include('request_info2/host')
      end

      it "follows local link correctly" do
        session.visit "/subsite/local_link_to_host"
        session.click_link "host"
        session.body.should include('request_info2/host')
      end
    end
  end
end
