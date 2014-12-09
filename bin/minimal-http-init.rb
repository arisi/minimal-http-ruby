#!/usr/bin/env ruby
# encode: UTF-8

require "fileutils"


puts "minimal-http-ruby Initializer"
if File.directory? "./http"
  puts "Error: ./http Already Exists -- Cannot create!"
  exit(-1)
end
Dir.mkdir "./http"
if File.directory? "./http"
  Dir.mkdir "./http/coffee"
  Dir.mkdir "./http/css"
  Dir.mkdir "./http/haml"
  Dir.mkdir "./http/json"
  File.open("./http/haml/index.haml", 'w') do |file|
  file.write <<END
!!!
%body
  %h1 Congratulations!
  %hr
  You have installed minimal-http-ruby
  %hr
  Next, please edit file: #{Dir.pwd}/http/haml to get started!

END
  end
  puts "Created OK!"
  puts "Next, please edit file: #{Dir.pwd}/http/haml to get started!"
end
