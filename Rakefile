# encoding: utf-8

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'strawberry'
    gem.summary = 'Tree-Oriented Table Data Storage.'
    gem.description = 'Tree-Oriented Table Data Storage based on TokyoCabinet.'
    gem.email = 'eveeel@gmail.com'
    gem.homepage = 'http://github.com/peppery/strawberry'
    gem.rubyforge_project = 'strawberry'
    gem.authors = [ 'Dmitry A. Ustalov' ]
    gem.add_development_dependency "shoulda", ">= 2.10.2"
    gem.add_dependency 'oklahoma_mixer', '>= 0.4.0'
    gem.add_dependency 'uuid', '>= 2.1.1'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available.'
  puts 'Install it with: sudo gem install jeweler'
end

task :test => :check_dependencies

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

require 'rake/rdoctask'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Strawberry Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort 'RCov is not available. Install it with: sudo gem install spicycode-rcov'
  end
end
