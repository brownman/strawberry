# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

module Strawberry::Test
  class Base < Test::Unit::TestCase
    context 'Strawberry Base Node Factory' do
      should 'have working factory method' do
        instance = Strawberry::Base.at Strawberry::Test::DATABASE_PATH
        assert_kind_of Strawberry::Base, instance
      end

      should 'not have working factory at non-existant directory' do
        assert_raise Errno::ENOENT do
          Strawberry::Base.at Strawberry::Test::DATABASE_PATH +
            Strawberry::Test.uuid
        end
      end
    end

    context 'Strawberry Base Node' do
      setup do
        @path = Strawberry::Test::DATABASE_PATH
      end

      subject { @base ||= Strawberry::Base.at @path }

      should 'be root' do
        assert_nil subject.name
        assert_nil subject.parent
      end
    end
  end
end
