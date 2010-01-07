# encoding: utf-8

module Strawberry
  require 'strawberry/node'

  class Base < Node
    require 'strawberry/dao'

    class << self
      def new(path)
        @cache ||= {}
        @cache[path] ||= uncached_new(path)
      end
    end

    def initialize(path)
      super(nil, self, DAO.new(path))
    end

    def inspect
      "#<#{self.class} @path=#{self.dao.path.inspect}>"
    end
  end
end
