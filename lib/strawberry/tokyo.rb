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
    Table, Cabinet = if defined? Rufus::Edo
      [ Rufus::Edo::Table, Rufus::Edo::Cabinet ]
    else
      [ Rufus::Tokyo::Table, Rufus::Tokyo::Cabinet ]
    end
  end
end
