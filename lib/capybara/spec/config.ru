require 'rubygems'

gemfile = File.expand_path('../../../../Gemfile', __FILE__)

begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

require 'sinatra'
require 'capybara'

require File.join(File.dirname(__FILE__), 'extended_test_app')

run ExtendedTestApp