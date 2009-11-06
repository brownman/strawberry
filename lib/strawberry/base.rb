# encoding: utf-8

module Strawberry
  module Base
    require 'strawberry/node'

    include Node
    extend Node

    class << self
      require 'strawberry/dao'

      def at path
        @buildings ||= {}

        unless @buildings.has_key? path
          base = self

          dao = DAO.at path
          # let's rock, I've got balls of steel!
          @buildings[path] = Class.new do
            include base

            define_method :initialize do
              @name, @base, @dao = nil, self, dao
            end
          end.new
        end

        # it's time to kick ass and chew bubble gum,
        # and I'm all outta gum.
        @buildings[path]
      end
    end
  end
end
