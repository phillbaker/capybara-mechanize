# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capybara-mechanize}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeroen van Dijk"]
  s.date = %q{2010-09-27}
  s.summary = %q{RackTest driver for Capybara with remote request support}
  s.description = %q{RackTest driver for Capybara, but with remote request support thanks to mechanize}

  s.email = %q{jeroen@jeevidee.nl}
  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.mdown)
  s.homepage = %q{http://github.com/jeroenvandijk/capybara-mechanize}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  
  s.add_runtime_dependency(%q<mechanize>, ["~> 1.0.0"])
  s.add_runtime_dependency(%q<capybara>, ["~> 0.4.0"])
end

