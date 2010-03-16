# encoding: utf-8

begin
  require 'oklahoma_mixer'
rescue LoadError
  require 'rubygems'
  retry
end

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

    attr_reader :path, :index_path, :data_path, :meta_path
    private :index_path, :data_path, :meta_path

    def initialize(path)
      @path = path
      @index_path = File.join path, 'index.tct'
      @data_path  = File.join path, 'database.tcb'
      @meta_path  = File.join path, 'metabase.tct'
    end

    # Check the table existance with <tt>id</td>.
    def have_table? id
      return true unless id
      raise InvalidName.new(id) unless valid_name?(id)
      session(index_path) do |index|
        index.include? id
      end
    end

    # Check the table existance with <tt>name</td>,
    # according to its <tt>parent_id</tt>.
    def have_named_table? name, parent_id = nil
      return true unless name
      return false unless valid_name?(name)
      raise NotFound.new(parent_id) unless have_table?(parent_id)

      session(index_path) do |index|
        index.all :conditions => [
          [ :parent, :==, parent_id ],
          [ :name, :==, name ]
        ]
      end.size != 0
    end

    # Returns the table name by its <tt>id</tt>.
    def get_name(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table?(id)

      session(index_path) do |index|
        row = index.fetch(id, {})
        row['name']
      end
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
      session(index_path) do |index|
        index.store(id, { 'parent' => parent_id, 'name' => name })
      end
      id
    end

    # Returns the data of table <tt>id</tt>.
    def get_data(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table?(id)

      result = session(data_path) do |db|
        db.values(id).map do |uuid|
          db.values(uuid)
        end
      end

      array_wrap(result).freeze
    end

    # Sets and returns the <tt>new_data</tt> of table <tt>id</tt>.
    def set_data(id, new_data)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table?(id)

      result = array_wrap(new_data)

      rewrite_data id do |db|
        db.transaction do
          idx = result.map do |arr|
            uuid = Strawberry.uuid
            db.store(uuid, arr, :dup)
            uuid
          end
          db.store(id, idx, :dup)
        end
      end

      result.freeze
    end

    # Returns the metadata of table <tt>id</tt>.
    def get_meta(id)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table?(id)

      session(meta_path) do |meta|
        meta.fetch(id, {}).freeze
      end
    end

    # Sets and returns the <tt>new_meta</tt> of table <tt>id</tt>.
    def set_meta(id, new_meta)
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table?(id)
      raise TypeError unless new_meta.instance_of? Hash

      session(meta_path) do |meta|
        meta.store(id, new_meta).freeze
      end
    end

    # Returns the parent id of table <tt>id</tt>.
    def get_parent id
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table?(id)

      parent_id = session(index_path) do |index|
        row = index.fetch(id, {})
        row['parent']
      end
      parent_id && parent_id.empty? ? nil : parent_id
    end

    # Returns the array of child's ids of table <tt>id</tt>.
    def get_childs id
      raise NotFound.new(id) unless have_table?(id)

      session(index_path) do |index|
        index.all :conditions => [ :parent, :==, id ]
      end.map { |r| r.first }.freeze
    end

    # Drop table <tt>id</tt> and return it's <tt>id</tt>.
    def remove_table id
      raise InvalidName.new(id) unless valid_name?(id)
      raise NotFound.new(id) unless have_table?(id)

      get_childs(id).each do |c|
        remove_table c if have_table? c
      end

      session(index_path) do |index|
        index.transaction do
          session(meta_path) do |meta|
            meta.delete id
          end
          rewrite_data id
          index.delete id
        end
      end

      id
    end

    def array_wrap obj
      obj = Array(obj)
      obj << [] if obj.empty?
      obj.map { |l| Array(l).map { |c| c.to_s } }
    end
    private :array_wrap

    def session(path)
      raise LocalJumpError unless block_given?
      db = OKMixer.open(path)
      begin
        yield db
      ensure
        db.close
      end
    end
    protected :session

    def rewrite_data id
      session(data_path) do |db|
        db.transaction do
          db.values(id).each do |uuid|
            db.delete(uuid, :dup)
          end
          db.delete(id, :dup)
        end
        yield db if block_given?
      end
      nil
    end
    protected :rewrite_data
  end
end
