#!/usr/bin/env ruby
# encode: UTF-8

require "fileutils"
require "rubygems"
require 'minimal-http-ruby'


puts "minimal-http-ruby Initializer"

target=ARGV[0]||"./http"

if File.directory? target
  puts "Error: #{target} Already Exists -- Cannot create!"
  exit(-1)
end

Dir.mkdir target
if File.directory? target
  puts "Copying Files..."
  path=File.join( Gem.loaded_specs['minimal-http-ruby'].full_gem_path, 'http/')
  FileUtils.cp_r "#{path}/.", "#{target}"
  puts "Created OK!"
  puts "Next, please edit file: #{target}/haml/index.haml to get started!"
  system "tree #{target}"
end
