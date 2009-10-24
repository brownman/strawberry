# encoding: utf-8

module Strawberry
  module Node
    attr_reader :name, :base, :dao
    private :base, :dao

    class << self
      def new name, base, dao
        @bases ||= {}

        @bases[base] ||= {}

        unless @bases[base].has_key? name
          node = self

          @bases[base][name] = Class.new do
            include node

            define_method :initialize do
              @name, @base, @dao = name, base, dao
            end
          end.new
        end

        @bases[base][name]
      end
    end

    def parent
      return nil if base == self
      Strawberry::Node.new dao.get_parent(name), base, dao
    end

    def childs
      dao.get_childs(name).map do |child_name|
        Strawberry::Node.new child_name, base, dao
      end.freeze
    end

    def child child_name
      child_name = child_name.split(/\./).last
      node_name = if name
        [ name, child_name ].join '.'
      else
        child_name
      end
      found = childs.find { |c| c.name == node_name }
      unless found
        add_child node_name
      else
        found
      end
    end
    alias :>> :child

    def add_child child_name
      dao.add_table child_name, name
      node = Strawberry::Node.new child_name, base, dao
      node
    end
    private :add_child

    def data
      dao.get_data(self.name)
    end

    def data=(val)
      dao.set_data(self.name, val)
    end

    def meta
      dao.get_meta self.name
    end

    def meta=(val)
      dao.set_meta(self.name, val)
    end

    def clean!
      dao.get_childs(name).each do |child_name|
        dao.remove_table child_name
      end.freeze
      self
    end
  end
end
