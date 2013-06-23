#!/usr/bin/env ruby

$:.unshift File.expand_path('./lib')
require 'sphero'
require 'yaml'

config = YAML.load( File.read('./config.yml') )
device_path = config['device_path']

print "Connecting to Sphero on #{device_path}..."

begin
  s = Sphero.new device_path
rescue Errno::EBUSY
  print '.'
  retry
rescue Interrupt
  puts "Aborted"
  exit!
end

trap(:INT) {
  s.stop
  exit!
}

puts "Connected"
s.ping
p s.user_led

# s.roll 100, 0
# sleep 2
# s.stop

loop do
  [0, 180].each do |dir|
    s.heading = dir
    sleep 3
  end

  # [
  #   [0, 0, 0xFF],
  #   [0xFF, 0, 0],
  #   [0, 0xFF, 0],
  # ].each do |color|
  #   s.rgb(*color)
  #   sleep 3
  # end
end

#36.times {
#  i = 10
#  p :step => i
#  s.heading = i
#  sleep 0.5
#}
