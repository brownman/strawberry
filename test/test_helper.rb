# encoding: utf-8

require 'fileutils'
require 'test/unit'
begin
  require 'shoulda'
rescue LoadError
  require 'rubygems'
  require 'shoulda'
end

$: << 'lib'

module Test::Unit::Assertions
  def assert_file_exist path, message = nil
    assert File.exist?(path), message ||
      "'#{path}': no such file or directory"
  end
end

require 'strawberry'

module Strawberry::Test
  DATABASE_PATH = File.expand_path File.join(File.dirname(__FILE__), 'db')

  class << self
    def perform_db_cleanup!
      FileUtils.rm_rf DATABASE_PATH
      FileUtils.mkdir_p DATABASE_PATH
    end
  end
end

Strawberry::Test.perform_db_cleanup!
