# encoding: utf-8

begin
  require 'uuid'
rescue LoadError
  require 'rubygems'
  require 'uuid'
end

module Strawberry
  class << self
    # Generate an Universally Unique Identifier (UUID) which
    # heavily used in Strawberry internals.
    def uuid
      @uuid ||= UUID.new
      @uuid.generate
    end
  end
end
