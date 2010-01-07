#!/usr/bin/env ruby

# encoding: utf-8

$: << '../lib'
require 'fileutils'
require 'strawberry'
require 'pp'

if File.directory? 'db'
  FileUtils.rm_rf 'db'
end
FileUtils.mkdir_p 'db'

def show table
  unless table.meta.empty?
    table.meta.each { |k, v| puts "#{k} = #{v}" }
    puts
  end
  unless table.data.empty?
    pp table.data
  end
end

LESSONS = [ 'math', 'lang', 'comp', 'piv4ik' ]

root = Strawberry::Base.new 'db'

school = root >> 'school'
timeline = school >> 'timelines'
classes = school >> 'classes'

timeline.data = (0..6).map do |i|
  [ [ "#{8 + i}", "00" ], [ "#{8 + i}", "30" ] ].map do |a|
    a.join(':')
  end
end

class1 = classes >> 'class1'
class1.data = [ 'Vasya', 'Petya', 'Masha' ]
class1.meta = { 'class_leader' => 'Maria Ivanovna' }

schedule1 = class1 >> 'schedule'
schedule1.data = (1..6).map do
  (1..(2 + rand(4))).map do
    LESSONS[rand(LESSONS.size)]
  end
end

class2 = classes >> 'class2'
class2.data = [ 'Boxer', 'Ashot', 'Ment', 'Driver', 'Biker', 'Sexy',
                'Conductor', 'Bandit' ]
class2.meta = { 'class_leader' => 'Booba' }

schedule2 = class2 >> 'schedule'
schedule2.data = (1..6).map do
  (1..(2 + rand(4))).map do
    LESSONS[rand(LESSONS.size)]
  end
end

puts '= Table: School Timeline'
show timeline
puts
puts '= Table: Class 1'
show class1
puts
puts '== Table: Class 1 Schedule'
show schedule1
puts
puts '= Table: Class 2'
show class2
puts
puts '== Table: Class 2 Schedule'
show schedule2
