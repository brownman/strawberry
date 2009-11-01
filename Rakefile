# encoding: utf-8

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'strawberry'
    gem.summary = 'Tree-Oriented Table Data Storage.'
    gem.description = 'Domain Specific Solution to store Table data into Tree hierarchy with Metadata.'
    gem.email = 'eveel@peppery.me'
    gem.homepage = 'http://github.com/peppery/strawberry'
    gem.authors = [ 'Dmitry A. Ustalov of Peppery' ]
    gem.add_dependency 'rufus-tokyo', '>= 1.0.1'
  end
  Jeweler::RubyforgeTasks.new
rescue
  puts 'Jeweler (or a dependency) not available.'
  puts 'Install it with: sudo gem install jeweler'
end

desc 'Default: run unit tests.'
task :default => :test

require 'rake/testtask'
desc 'Test Strawberry.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

require 'rake/rdoctask'
desc 'Generate documentation for Strawberry.'
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
