# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'capybara/mechanize/version'

Gem::Specification.new do |s|
  s.name = 'capybara-mechanize'
  s.version = Capybara::Mechanize::VERSION
  s.required_ruby_version = '>= 2.6.0'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Jeroen van Dijk']
  s.summary = 'RackTest driver for Capybara with remote request support'
  s.description = 'RackTest driver for Capybara, but with remote request support thanks to mechanize'

  s.email = 'jeroen@jeevidee.nl'
  s.files = Dir.glob('{lib,spec}/**/*') + %w[README.mdown]
  s.homepage = 'https://github.com/jeroenvandijk/capybara-mechanize'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.rubygems_version = '1.3.7'

  s.add_runtime_dependency('capybara', ['>= 3.0.0', '< 4'])
  s.add_runtime_dependency('mechanize', ['>= 2.8.5', '< 3'])

  s.add_development_dependency('launchy', ['>= 2.0.4'])
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('rspec', ['~>3.5'])
end
