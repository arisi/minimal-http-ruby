#!/usr/bin/env ruby
# encode: UTF-8


if File.file? './lib/minimal-http-ruby.rb'
  require './lib/minimal-http-ruby.rb'
  puts "using local http lib"
else
  require 'minimal-http-ruby'
end

minimal_http_server http_port: 8088, http_path: "./http/"

loop do
  sleep 1 
end
