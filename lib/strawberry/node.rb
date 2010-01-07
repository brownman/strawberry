# encoding: utf-8

module Strawberry
  class Node
    attr_reader :id, :base, :dao
    protected :base, :dao

    class << self
      alias :uncached_new :new
      protected :uncached_new

      alias :instance :new
      private :instance

      def new id, base, dao
        @cache ||= {}
        @cache[base] ||= {}
        @cache[base][id] ||= instance(id, base, dao)
      end
    end

    def initialize(id, base, dao)
      @id, @base, @dao = id, base, dao
    end

    def inspect
      "#<#{self.class}:#{self.id} @name=#{self.name.inspect} @childs=#{self.childs.size}>"
    end

    # Is this Node root?
    def root?
      base == self
    end

    # Nome of this Node.
    def name
      return nil if root?
      dao.get_name(self.id)
    end

    # Parent of this Node.
    def parent
      return nil if root?
      Strawberry::Node.new dao.get_parent(self.id), base, dao
    end

    # Childs of this Node.
    def childs
      dao.get_childs(self.id).map do |child_id|
        Strawberry::Node.new child_id, base, dao
      end.freeze
    end

    # Specified child of this Node.
    def child child_name
      found = childs.find { |c| c.name == child_name }
      unless found
        add_child child_name
      else
        found
      end
    end
    alias :>> :child

    def add_child child_name
      child_id = dao.add_table child_name, self.id
      Strawberry::Node.new child_id, base, dao
    end
    private :add_child

    # Node data.
    def data
      dao.get_data(self.id)
    end

    # Node data assignment.
    def data=(val)
      dao.set_data(self.id, val)
    end

    # Node metadata.
    def meta
      dao.get_meta self.id
    end

    # Node metadata assignment.
    def meta=(val)
      dao.set_meta(self.id, val)
    end

    # Remove all childs of this Node.
    def clean!
      dao.get_childs(self.id).each do |child_id|
        dao.remove_table child_id
      end.freeze
      self
    end

    # Is this Node removed?
    def removed?
      !dao.have_table? self.id
    end
  end
end
