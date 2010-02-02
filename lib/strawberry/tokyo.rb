# encoding: utf-8

begin
  require 'rufus/edo'
rescue LoadError
  require 'rubygems'
  begin
    require 'rufus/edo'
  rescue LoadError
    require 'rufus/tokyo'
  end
end

module Strawberry
  module Tokyo
    module Origin
      Table, Cabinet = if defined? Rufus::Edo
        [ Rufus::Edo::Table, Rufus::Edo::Cabinet ]
      else
        [ Rufus::Tokyo::Table, Rufus::Tokyo::Cabinet ]
      end
    end

    module Proxy
      attr_reader :path, :tokyo

      def [] k
        self.session do |db|
          db[k]
        end
      end

      def []= k, v
        self.session do |db|
          db[k] = v
        end
      end

      def has? k
        self.session do |db|
          !!db[k]
        end
      end

      def delete k
        self.session do |db|
          db.delete k while !!db[k]
        end
      end

      def session
        return nil unless block_given?
        db = tokyo.new(path)
        result = yield db
        db.close
        result
      end
      protected :session
    end

    class Cabinet
      include Proxy

      def initialize(path)
        @path = path
        @tokyo = Origin::Cabinet
      end

      def [] k
        session do |db|
          !!db[k] ? db.getdup(k) : nil
        end || []
      end

      def []= k, v
        session do |db|
          db.ldelete k while !!db[k]
          v.each { |e| db.putdup k, e }
        end
        v
      end
    end

    class Table
      include Proxy

      def initialize(path)
        @path = path
        @tokyo = Origin::Table
      end

      def query &block
        session do |db|
          db.query(&block).to_a
        end
      end
    end
  end
end
