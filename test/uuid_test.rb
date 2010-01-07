# encoding: utf-8

require File.dirname(__FILE__) + '/test_helper'

module Strawberry::Test
  class UUID < Test::Unit::TestCase
    context 'Strawberry UUID Generator' do
      should 'generate good values at short time intervals' do
        uuids = (0...20).map { Strawberry.uuid }
        assert_equal uuids.size, uuids.uniq.size
      end
    end
  end
end
