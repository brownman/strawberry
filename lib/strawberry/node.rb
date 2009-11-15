# encoding: utf-8

module Strawberry
  module Node
    attr_reader :id, :base, :dao
    private :base, :dao

    class << self
      def new id, base, dao
        @bases ||= {}

        @bases[base] ||= {}

        unless @bases[base].has_key? id
          node = self

          @bases[base][id] = Class.new do
            include node

            define_method :initialize do
              @id, @base, @dao = id, base, dao
            end
          end.new
        end

        @bases[base][id]
      end
    end

    def root?
      base == self
    end

    def name
      return nil if root?
      dao.get_name(self.id)
    end

    def parent
      return nil if root?
      Strawberry::Node.new dao.get_parent(self.id), base, dao
    end

    def childs
      dao.get_childs(self.id).map do |child_id|
        Strawberry::Node.new child_id, base, dao
      end.freeze
    end

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

    def data
      dao.get_data(self.id)
    end

    def data=(val)
      dao.set_data(self.id, val)
    end

    def meta
      dao.get_meta self.id
    end

    def meta=(val)
      dao.set_meta(self.id, val)
    end

    def clean!
      dao.get_childs(self.id).each do |child_id|
        dao.remove_table child_id
      end.freeze
      self
    end

    def removed?
      !dao.have_table? self.id
    end
  end
end
