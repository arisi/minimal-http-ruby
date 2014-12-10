#!/usr/bin/env ruby

require 'minimal-http-ruby'
require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely; creates protocol log on console (false)") do |v|
    options[:verbose] = v
  end

  options[:http_port]=8088
  opts.on("-p", "--http_port port", "Local port to listen (8088)") do |v|
    options[:http_port] = v.to_i
  end
  options[:http_path]="./http/"
  opts.on("-d", "--http_path path", "Location of http files to serve (./http/)") do |v|
    options[:http_path] = v
  end
end.parse!

puts "ok"
pp options
minimal_http_server options

loop do #or whatever you need to do
    sleep 1
end
