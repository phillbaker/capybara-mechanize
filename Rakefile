require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "capybara-mechanize #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "capybara-mechanize"
    s.summary = "RackTest driver for Capybara with remote request support."
    s.description = "RackTest driver for Capybara, but with remote request support thanks to mechanize."
    s.email = "jeroen@jeevidee.nl"
    s.homepage = "http://github.com/jeroenvandijk/capybara-mechanize"
    s.authors = ["Jeroen van Dijk"]
    s.rdoc_options = ["--charset=UTF-8"]

    s.add_runtime_dependency("mechanize", ["~> 1.0"])

    s.add_development_dependency("rspec", [">= 2.0.0.beta.22"])
    s.add_development_dependency("jeweler")
    s.add_development_dependency("sinatra")
    s.add_development_dependency("mongrel", [">= 1.2.pre"])
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end