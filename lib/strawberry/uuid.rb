# encoding: utf-8

# conversions are took from O'Reilly's Ruby Cookbook
class DateTime
  def to_local_time
    to_time(new_offset(DateTime.now.offset - offset), :local)
  end

  def to_time dest, method
    usec = (dest.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
    Time.send(method, dest.year, dest.month, dest.day, dest.hour,
      dest.min, dest.sec, usec)
  end
  private :to_time
end

require 'digest/sha2'

module Strawberry
  class << self
    def uuid now = DateTime.now
      time_now = now.to_local_time

      time_salt = time_now.strftime '%X'
      date_salt = now.strftime '%F'

      salt = "%s\t%s:%d" % [ date_salt, time_salt, time_now.usec ]

      Digest::SHA2.hexdigest salt
    end
  end
end
