# encoding: utf-8

module Strawberry
  module DAO
    VALID_NAME_PATTERN = /^[A-z_\-0-9]+$/

    def valid_name?(name)
      # only A-Z a-z '_' '-'
      name && !name.match(VALID_NAME_PATTERN).nil?
    end
    private :valid_name?

    class InvalidName < RuntimeError
      attr_reader :name
      def initialize name
        super("invalid table name '#{name}' not matches " +
            VALID_NAME_PATTERN.inspect)
        @name = name
      end
    end

    class NotFound < RuntimeError
      attr_reader :name
      def initialize name
        super("table '#{name}' is not found")
        @name = name
      end
    end

    class AlreadyExists < RuntimeError
      attr_reader :name
      def initialize name
        super("table '#{name}' already exists!")
        @name = name
      end
    end

    class << self
      def at path
        @buildings ||= {}

        unless File.directory? path
          raise Errno::ENOENT, path
        end

        unless @buildings.has_key? path
          base = self

          @buildings[path] = Class.new do
            include base

            attr_reader :index, :data, :meta, :path
            private :index, :data, :meta

            define_method :initialize do
              @path = path

              index_path = File.join @path, 'index.tct'
              @index = Tokyo::Table.new(index_path, :mode => 'wcefs')

              data_path = File.join @path, 'database.tch'
              @data = Tokyo::Cabinet.new(data_path, :mode => 'wcef')

              meta_path = File.join @path, 'metabase.tct'
              @meta = Tokyo::Table.new(meta_path, :mode => 'wcefs')
            end
          end.new
        end

        @buildings[path]
      end
    end

    def have_table? id
      return true unless id
      valid_name?(id) && index[id]
    end

    def have_named_table? name, parent_id = nil
      return true unless name
      return false unless valid_name?(name)

      !!get_childs(parent_id).find do |c|
        index[c]['name'] == name
      end
    end

    def get_name(id)
      return NotFound.new(id) unless have_table? id
      index[id]['name']
    end

    def add_table(name = Strawberry.uuid, parent_id = nil)
      raise InvalidName.new(name) unless valid_name?(name)
      raise AlreadyExists.new(name) if have_named_table? name
      if parent_id && !have_table?(parent_id)
        raise NotFound.new(parent_id)
      end

      id = Strawberry.uuid
      index[id] = { 'parent' => parent_id, 'name' => name }
      id
    end

    def get_data(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      array_wrap(Marshal.load(data[id])).freeze
    rescue TypeError
      [ [] ]
    end

    def set_data(id, new_data)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      new_data = array_wrap(new_data)

      (data[id] = Marshal.dump(new_data)).freeze
    end

    def get_meta(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      (meta[id] || {}).freeze
    end

    def set_meta(id, new_meta)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id
      raise TypeError unless new_meta.instance_of? Hash

      (meta[id] = new_meta).freeze
    end

    def get_parent id
      return nil unless id
      raise NotFound.new(id) unless have_table? id

      index[id]['parent']
    end

    def get_childs id
      raise NotFound.new(id) unless have_table? id

      index.query do |q|
        q.add_condition :parent, :eq, id
      end.map { |r| r[:pk] }
    end

    def remove_table id
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      get_childs(id).each do |c|
        remove_table c if have_table? c
      end

      data.delete id
      meta.delete id
      index.delete id

      id
    end

    def array_wrap obj
      obj = Array(obj)
      obj << [] if obj.empty?
      obj.map { |l| Array(l).map { |c| c.to_s } }
    end
    private :array_wrap
  end
end
