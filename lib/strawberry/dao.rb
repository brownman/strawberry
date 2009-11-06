# encoding: utf-8

module Strawberry
  module DAO
    VALID_NAME_PATTERN = /^[A-z_\-0-9\.]+$/

    def valid_name?(name)
      # only A-Z a-z '_' '-'
      name && !name.match(VALID_NAME_PATTERN).nil?
    end
    private :valid_name?

    class InvalidName < RuntimeError
      attr_reader :name
      def initialize name
        super("invalid table name '#{name}' not matches #{VALID_NAME_PATTERN}")
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
              @index = Rufus::Tokyo::Table.new(index_path, :mode => 'wcefs')

              data_path = File.join @path, 'database.tch'
              @data = Rufus::Tokyo::Cabinet.new(data_path, :mode => 'wcef')

              meta_path = File.join @path, 'metabase.tct'
              @meta = Rufus::Tokyo::Table.new(meta_path, :mode => 'wcefs')
            end
          end.new
        end

        @buildings[path]
      end
    end

    def table_exist? name
      return true unless name
      valid_name?(name) && index[name]
    end

    def add_table(name, parent_name = nil)
      raise InvalidName.new(name) unless valid_name?(name)
      raise AlreadyExists.new(name) if table_exist? name
      if parent_name && !table_exist?(parent_name)
        raise NotFound.new(parent_name)
      end

      index[name] = { 'parent' => parent_name }
      name
    end

    def get_data(name)
      raise NotFound.new(name) unless table_exist? name

      array_wrap(Marshal.load(data[name])).freeze
    rescue TypeError
      [ [] ]
    end

    def set_data(name, new_data)
      raise NotFound.new(name) unless table_exist? name

      new_data = array_wrap(new_data)

      (data[name] = Marshal.dump(new_data)).freeze
    end

    def get_meta(name)
      raise NotFound.new(name) unless table_exist? name

      (meta[name] || {}).freeze
    end

    def set_meta(name, new_meta)
      raise NotFound.new(name) unless table_exist? name
      raise TypeError unless new_meta.instance_of? Hash

      (meta[name] = new_meta).freeze
    end

    def get_parent name
      return nil unless name
      raise NotFound.new(name) unless table_exist? name

      index[name]['parent']
    end

    def get_childs name
      raise NotFound.new(name) unless table_exist? name

      index.query do |q|
        q.add_condition :parent, :eq, name
      end.map { |r| r[:pk] }
    end

    def remove_table name
      raise NotFound.new(name) unless table_exist? name

      get_childs(name).each do |c|
        remove_table c if table_exist? c
      end

      data.delete name
      meta.delete name
      index.delete name

      name
    end

    def array_wrap obj
      obj = Array(obj)
      obj << [] if obj.empty?
      obj.map { |l| Array(l).map { |c| c.to_s } }
    end
    private :array_wrap
  end
end
