# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

module Strawberry::Test
  class DAO < Test::Unit::TestCase
    context 'Strawberry DAO Factory' do
      should 'have working factory method' do
        instance = Strawberry::DAO.at Strawberry::Test::DATABASE_PATH
        assert_kind_of Strawberry::DAO, instance
      end

      should 'not have working factory at non-existant directory' do
        assert_raise Errno::ENOENT do
          Strawberry::DAO.at Strawberry::Test::DATABASE_PATH +
            Strawberry::Test.uuid
        end
      end
    end

    context 'Strawberry DAO' do
      setup do
        @path = Strawberry::Test::DATABASE_PATH
      end

      subject { @dao = Strawberry::DAO.at @path }

      should 'have allocated databases' do
        [ 'database.tch', 'index.tct', 'metabase.tct' ].each do |db|
          assert_file_exist File.join(Strawberry::Test::DATABASE_PATH, db)
        end
      end

      should 'validate format of table name' do
        [ nil, 'check!', '$asd', '+a', '', 'хуй-пизда' ].each do |name|
          assert_raise Strawberry::DAO::InvalidName do
            subject.add_table name
          end
        end
      end

      should 'add new table' do
        table = subject.add_table Strawberry::Test.uuid
        assert subject.table_exist?(table)
      end

      should 'have no data and metadata on new table' do
        table = subject.add_table Strawberry::Test.uuid
        assert_equal [ [] ], subject.get_data(table)
        assert_equal Hash.new, subject.get_meta(table)
      end

      should 'set table data' do
        table = subject.add_table Strawberry::Test.uuid
        assert_nothing_raised do
          subject.set_data table, [ [ 1, 2, 3 ] ]
        end
        assert_equal [ [ '1', '2', '3' ] ], subject.get_data(table)
      end

      should 'not set table data on not-existant table' do
        table = Strawberry::Test.uuid
        data = [ [ 1, 2, 3 ] ]
        assert_raise Strawberry::DAO::NotFound do
          subject.set_data table, data
        end
      end

      should 'tablize data' do
        table = subject.add_table Strawberry::Test.uuid

        subject.set_data table, []
        assert_equal [ [] ], subject.get_data(table)

        subject.set_data table, [ [] ]
        assert_equal [ [] ], subject.get_data(table)

        subject.set_data table, 'delicious flat chest'
        assert_equal [ [ 'delicious flat chest' ] ],
          subject.get_data(table)

        subject.set_data table, [ 1, 2, 3 ]
        assert_equal [ [ '1' ], [ '2' ], [ '3' ] ],
          subject.get_data(table)

        subject.set_data table, [ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
        assert_equal [ [ '1', '2', '3' ], [ '4', '5', '6' ] ],
          subject.get_data(table)
      end

      should 'correctly store some non-flat 2D data' do
        table = subject.add_table Strawberry::Test.uuid

        ints = (1..100).map { |a| Array(1..a) }
        strs = ints.map { |a| a.map { |i| i.to_s } }

        subject.set_data table, ints
        assert_equal strs, subject.get_data(table)
      end

      should 'froze data' do
        table = subject.add_table Strawberry::Test.uuid
        res = subject.set_data table, [ 'dfc sucks' ]
        assert res.frozen?
        res = subject.get_data table
        assert res.frozen?
      end

      should 'set table metadata' do
        table = subject.add_table Strawberry::Test.uuid
        meta = { 'dfc' => 'flat bitch', 'buba' => 'suka debil' }
        assert_nothing_raised { subject.set_meta table, meta }
        assert_equal meta, subject.get_meta(table)
      end

      should 'not set table metadata on not-existant table' do
        table = Strawberry::Test.uuid
        meta = { 'dfc' => 'flat bitch', 'buba' => 'suka debil' }
        assert_raise Strawberry::DAO::NotFound do
          subject.set_meta table, meta
        end
      end

      should 'validate metadata format' do
        table = subject.add_table Strawberry::Test.uuid
        assert_raise TypeError do
          subject.set_meta table, [ 'delicious', 'flat', 'chest' ]
        end
      end

      should 'froze metadata' do
        table = subject.add_table Strawberry::Test.uuid
        res = subject.set_meta(table, { 'dfc' => 'sucks' })
        assert res.frozen?
        res = subject.get_meta table
        assert res.frozen?
      end

      should 'add table child' do
        root = subject.add_table Strawberry::Test.uuid
        child = subject.add_table Strawberry::Test.uuid, root
        assert subject.table_exist?(child)
      end

      should 'not add child to not-existant parent table' do
        root = Strawberry::Test.uuid
        assert_raise Strawberry::DAO::NotFound do
          child = subject.add_table Strawberry::Test.uuid, root
        end
      end

      should 'find parent of table' do
        root = subject.add_table Strawberry::Test.uuid
        child = subject.add_table Strawberry::Test.uuid, root
        assert_equal root, subject.get_parent(child)
      end

      should 'not find parent of not-existant table' do
        root = subject.add_table Strawberry::Test.uuid
        child = Strawberry::Test.uuid
        assert_raise Strawberry::DAO::NotFound do
          subject.get_parent child
        end
      end

      should 'find childs of table' do
        root = subject.add_table Strawberry::Test.uuid
        childs = (1..3).map do
          subject.add_table Strawberry::Test.uuid, root
        end
        assert_equal childs, subject.get_childs(root)
      end

      should 'not find childs of not-existant table' do
        root = Strawberry::Test.uuid
        assert_raise Strawberry::DAO::NotFound do
          subject.get_childs root
        end
      end

      should 'validate uniqueness of table name' do
        name = Strawberry::Test.uuid
        table = subject.add_table name
        assert_raise Strawberry::DAO::AlreadyExists do
          subject.add_table name
        end
      end

      should 'remove table' do
        root = subject.add_table Strawberry::Test.uuid
        child1 = subject.add_table Strawberry::Test.uuid, root
        child2 = subject.add_table Strawberry::Test.uuid, root
        child1a = subject.add_table Strawberry::Test.uuid, child1
        child1b = subject.add_table Strawberry::Test.uuid, child1

        assert_nothing_raised { subject.remove_table root }

        [ child1, child1a, child1b, child2 ].each do |child|
          assert !subject.table_exist?(child)
          assert_raise Strawberry::DAO::NotFound do
            subject.get_parent child
          end
        end

        assert !subject.table_exist?(root)
      end

      should 'not remove not-existant table' do
        table = Strawberry::Test.uuid
        assert_raise Strawberry::DAO::NotFound do
          subject.remove_table table
        end
      end
    end
  end
end
