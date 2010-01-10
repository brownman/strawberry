#!/usr/bin/env ruby

# encoding: utf-8

$: << '../lib'
require 'strawberry'

def roll node, path = []
  p node
  path << node.name
  unless node.root?
    puts [ path.join('/'), node.meta.inspect ].join(' : ')
    puts '['
    node.data.each do |d|
      print "\t"
      puts d.inspect
    end
    puts ']'
  end
  node.childs.each { |c| roll c, path.dup }
end

roll Strawberry::Base.new(ARGV.first)
