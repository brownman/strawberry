# encoding: utf-8

module Strawberry
  class DAO
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
      alias :instance :new
      private :instance

      def new path
        unless File.directory? path
          raise Errno::ENOENT, path
        end

        @cache ||= {}
        @cache[path] ||= instance(path)
      end
    end

    #attr_reader :index, :data, :meta, :path
    #private :index, :data, :meta
    attr_reader :index, :data, :meta, :path
    private :index, :data, :meta

    def initialize(path)
      @path = path

      index_path = File.join @path, 'index.tct'
      @index = Tokyo::Table.new(index_path)

      data_path = File.join @path, 'database.tcb'
      @data = Tokyo::Cabinet.new(data_path)

      meta_path = File.join @path, 'metabase.tct'
      @meta = Tokyo::Table.new(meta_path)
    end

    # Check the table existance with <tt>id</td>.
    def have_table? id
      return true unless id
      valid_name?(id) && index[id]
    end

    # Check the table existance with <tt>name</td>,
    # according to its <tt>parent_id</tt>.
    def have_named_table? name, parent_id = nil
      return true unless name
      return false unless valid_name?(name)

      !!get_childs(parent_id).find do |c|
        index[c]['name'] == name
      end
    end

    # Returns the table name by its <tt>id</tt>.
    def get_name(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id
      index[id]['name']
    end

    # Adds a new table with specified <tt>name</tt> and
    # <tt>parent_id</tt> and returns its UUID.
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

    # Returns the data of table <tt>id</tt>.
    def get_data(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      read = data[id].map { |uuid| data[uuid] }

      # enjoy
      array_wrap(read).freeze
    end

    # Sets and returns the <tt>new_data</tt> of table <tt>id</tt>.
    def set_data(id, new_data)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      saved = array_wrap(new_data)

      remove_data id

      # TODO: transactions will be nice
      data[id] = saved.map do |array|
        uuid = Strawberry.uuid
        data[uuid] = array
        uuid
      end

      saved.freeze
    end

    # Returns the metadata of table <tt>id</tt>.
    def get_meta(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      (meta[id] || {}).freeze
    end

    # Sets and returns the <tt>new_meta</tt> of table <tt>id</tt>.
    def set_meta(id, new_meta)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id
      raise TypeError unless new_meta.instance_of? Hash

      (meta[id] = new_meta).freeze
    end

    # Returns the parent id of table <tt>id</tt>.
    def get_parent id
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      parent_id = index[id]['parent']
      parent_id && parent_id.empty? ? nil : parent_id
    end

    # Returns the array of child's ids of table <tt>id</tt>.
    def get_childs id
      raise NotFound.new(id) unless have_table? id

      index.query do |q|
        q.add_condition :parent, :eq, id
      end.map { |r| r[:pk] }
    end

    def remove_data id
      data[id].each { |uuid| data.delete uuid }
      data.delete id
      nil
    end
    private :remove_data

    # Drop table <tt>id</tt> and return it's <tt>id</tt>.
    def remove_table id
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table? id

      get_childs(id).each do |c|
        remove_table c if have_table? c
      end

      remove_data id
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
