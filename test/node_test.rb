# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

module Strawberry::Test
  class Node < Test::Unit::TestCase
    context 'Strawberry Node Factory' do
      setup do
        @path = Strawberry::Test::DATABASE_PATH
        # factories prevents of creating more than one DAO/Base/Node
        # instance for one entity (path or tree node)
        @dao ||= Strawberry::DAO.at @path
        @base ||= Strawberry::Base.at @path
      end

      should 'have working factory method' do
        instance = Strawberry::Node.new(Strawberry::Test.uuid, @base, @dao)
        assert_kind_of Strawberry::Node, instance
      end
    end

    context 'Strawberry Node' do
      setup do
        @path = Strawberry::Test::DATABASE_PATH
        @base ||= Strawberry::Base.at @path
      end

      subject { @node ||= @base >> Strawberry::Test.uuid }

      should 'not be root' do
        assert_not_nil subject.name
        assert_not_nil subject.parent
      end

      should 'have childs' do
        child1 = subject >> Strawberry::Test.uuid
        child2 = child1 >> Strawberry::Test.uuid
        assert_contains subject.childs, child1
        assert_contains child1.childs, child2
      end

      should 'walk by childs' do
        child1 = subject >> Strawberry::Test.uuid
        child2 = child1 >> Strawberry::Test.uuid
        assert_same child1, subject.child(child1.name)
        assert_same child2, subject.child(child1.name).child(child2.name)
      end

      should 'create childs on demand' do
        name = Strawberry::Test.uuid
        assert_nothing_raised { subject.child name }
      end

      should 'not duplicate childs on demand' do
        name = Strawberry::Test.uuid
        test = subject >> name
        assert_same subject >> name, test
      end

      should 'acts as tree' do
        node1 = subject >> Strawberry::Test.uuid
        node2 = subject >> Strawberry::Test.uuid
        common_name = Strawberry::Test.uuid
        assert node1.childs.size == 0
        assert node2.childs.size == 0
        assert_nothing_raised do
          node1 >> common_name
          node2 >> common_name
        end
        assert node1.childs.size == 1
        assert node2.childs.size == 1
      end

      should 'have data' do
        data = [ [ 1, 2, 3 ] ]
        assert_nothing_raised { subject.data = data }
        assert_equal data, subject.data
      end

      should 'have metadata' do
        meta = { 'piv4ik' => 'jalo', 'pir' => 'otstoy' }
        assert_nothing_raised { subject.meta = meta }
        assert_equal meta, subject.meta
      end

      should 'clean' do
        child1 = subject >> Strawberry::Test.uuid
        child1 >> Strawberry::Test.uuid
        child2 = subject >> Strawberry::Test.uuid
        assert_nothing_raised { subject.clean! }
        assert subject.childs.empty?
      end

      should 'not have data or metadata on not-exitant tree node' do
        child = subject >> Strawberry::Test.uuid
        subject.clean!
        assert_raise Strawberry::DAO::NotFound do
          child.data = [ 'fail' ]
        end
        assert_raise Strawberry::DAO::NotFound do
          child.data
        end
        assert_raise Strawberry::DAO::NotFound do
          child.meta = { 'should' => 'fail' }
        end
        assert_raise Strawberry::DAO::NotFound do
          child.meta
        end
      end
    end
  end
end