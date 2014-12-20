#!/usr/bin/env ruby
# encode: UTF-8

require "haml"
require "coffee-script"
require "pp"
require 'socket'
require 'json'
require 'uri'
require 'ipaddr'
require 'time'
require 'thread'
require 'mimemagic'
require 'cgi'

$sessions={}

def minimal_http_server options={}
  prev_t={}
  cache={}
  ports=['127.0.0.1']
  if Socket.method_defined? :getifaddrs
    ports=Socket.getifaddrs.map { |i| i.addr.ip_address if i.addr.ipv4? }.compact
    puts "Starting HTTP services at port #{options[:http_port]}, server IPs: #{ports}"
  else
    puts "Starting HTTP services at port #{options[:http_port]}."
  end
  if options[:http_path]
    $http_dir=options[:http_path]
  elsif File.directory? './http'
    $http_dir="http/"
  else
    $http_dir = File.join( Gem.loaded_specs['minimal-http-ruby'].full_gem_path, 'http/')
  end
  if not File.directory? $http_dir
    puts "Warning: Http-path does not exist? -- Please create and populate!\nYou can use utility 'minimal-http-init.rb'"
  end
  puts "Serving pages from home directory: '#{$http_dir}'"
  statuses={ "200" => "OK", "404" => "Not Found", "500" => "Internal Server Error"}
  Thread.new(options[:http_port],options[:app_name]) do |http_port,http_app|
    server = TCPServer.new("0.0.0.0",http_port)
    @http_sessions={}
    http_session_counter=1
    loop do
      Thread.start(server.accept) do |client|
        begin
          @start=Time.now
          client_port= client.peeraddr[1]
          client_ip= client.peeraddr[2]
          raw=client.gets
          if not raw
            puts "#{client_ip}:#{client_port} #{Time.now.iso8601} ?? nil request?" if options[:verbose]
            client.close
            next
          end
          raw=raw.chop
          method,req,http_proto = raw.split " "
          #puts "method:#{method}"
          #pp req
          status="200"
          type="text/html"
          req="/#{http_app||'index'}.html" if req=="/" or req=="/index.htm" or req=="/index.html"
          args={}
          argss=nil
          if method=="GET"
            req,argss=req.split "\?"
          else
            len=0
            while line = client.gets
              puts "POST>#{line}"
              len=$1.to_i  if line[/Content-Length: (\d+)/]
              break if line=="\r\n"
            end
            argss=""
            while argss.size<len
              argss+=client.readpartial(len-argss.size)
              puts argss
            end
            #argss=URI.decode(argss)
            puts argss
          end
          if argss
            argss.split("&").each do |a|
              #puts ">>><found '#{a}'"
              if a
                k,v=a.split "="
                next if not v
                next if not k
                k=CGI.unescape(k).force_encoding("UTF-8")
                v=CGI.unescape(v).force_encoding("UTF-8")
                #args[k]=CGI.unescape(CGI.unescape(v)) #.force_encoding("UTF-8")
                if k[/(.+)\[\]$/]
                  #puts "IS ARRAY--------------------- #{k} #{$1}"
                  args[$1]=[] if not args[$1]
                  args[$1]<<v
                else
                  args[k]=v #CGI.unescape(v) #.force_encoding("UTF-8")
                end
                #puts "'#{v}' --> #{args[k]}"
              end
            end
            #puts "args:"
            #pp args
            #puts "------"
          end
          if req[/\.html$/] and File.file?(fn="#{$http_dir}haml#{req.gsub('.html','.haml')}")
            contents = File.read(fn) # never cached -- may be dynamically generated
            response=Haml::Engine.new(contents).render
          elsif req[/\.js$/] and File.file?(fn="#{$http_dir}coffee#{req.gsub('.js','.coffee')}")
            type="application/javascript"
            t=File.mtime(fn)
            if not prev_t[fn] or prev_t[fn]<t
              contents = File.read(fn)
              begin
                response=CoffeeScript.compile contents.force_encoding("UTF-8")
                prev_t[fn]=t
                cache[fn]=response
              rescue => e
                puts "**** COFFEE #{fn} failed:  #{e}"
                pp e.backtrace
                type="text/html"
                status="500"
                response="Coffee Compile error: #{e}"
              end
            else
              response=cache[fn]
            end
          elsif req[/^\/(.+)\.json$/] and File.file?(fn="#{$http_dir}json#{req.gsub('.json','.rb')}")
            req[/\/(.+).json$/]
            act=$1
            t=File.mtime(fn)
            if not prev_t[fn] or prev_t[fn]<t
              begin
                load_ok=load fn
                prev_t[fn]=t
              rescue Exception => e
                puts "**** RELOAD #{fn} failed:  #{e}"
                pp e.backtrace
                response=[{act: :error, msg:"Error loading JSON",alert: "Load error #{e} in #{fn}"}].to_json
                type="application/json"
                status="404"
              end
            end
            if type!="text/event-stream" and status=="200"
              begin
                type,response=eval "json_#{act} [method,req,http_proto],args,0,0"  #event handlers get called with zero session => init :)
                response=response.to_json
              rescue => e
                puts "**** AJAX EXEC #{fn} failed:  #{e}"
                pp e.backtrace
                response=[{act: :error, msg:"Error executing JSON",alert: "Syntax error '#{e}' in '#{fn}'"}].to_json
                type="application/json"
              end
             end
          elsif File.file?(fnc="#{$http_dir}#{req}")
            type=MimeMagic.by_path(req)
            t=File.mtime(fnc)
            if not prev_t[fnc] or prev_t[fnc]<t
              contents = File.read(fnc)
              response=contents
              prev_t[fnc]=t
              cache[fnc]=response
            else
              response=cache[fnc]
            end
          else
            status="404"
            response="Not Found: #{req}"
          end
          client.print "HTTP/1.1 #{status} #{statuses[status]||'???'}\r\nContent-Type: #{type}\r\n"
          if type!="text/event-stream"
            client.print "Content-Length: #{response.bytesize}\r\n"
            client.print "Connection: close\r\n"
            client.print "Access-Control-Allow-Origin: *\r\n"
            client.print "\r\n"
            client.print response
          else
            client.print "Expires: -1\r\n"
            client.print "Access-Control-Allow-Origin: *\r\n"
            client.print "\r\n"
            my_session=nil
            begin
              my_session=client.peeraddr[1]
              if not @http_sessions[my_session]
                @http_sessions[my_session]={client_port:client.peeraddr[1],client_ip:client.peeraddr[2] , log_position:0 }
              end
              $sessions[my_session]={}
              my_event=0
              loop do
                begin
                  type,response=eval "json_#{act} raw,args,my_session,my_event"
                  my_event+=1
                rescue => e
                  puts "**** AJAX EXEC #{fn} failed:  #{e}"
                  puts "#{e.backtrace[0..2]}"
                  pp e.backtrace
                  response=[{act: :error, msg:"Error executing JSON",alert: "Syntax error '#{e}' in '#{fn}'"}].to_json
                end
                if not response or response==[] or response=={}
                else
                  client.print  "retry: 1000\n"
                  client.print  "data: #{response.to_json}\n\n"
                end
                sleep 0.001
                break if my_event>10000
              end
            rescue Errno::EPIPE
              #quite normal ;)
            rescue => e
              puts "stream #{client} died #{e}"
              pp e.backtrace
            end
            if my_session and $sessions[my_session] and $sessions[my_session][:thread] and $sessions[my_session][:thread].status
              puts "HEY SOMETHING WAS RUNNING"
              $sessions[my_session][:thread].kill
            end
          end
          dur=sprintf "%.2f",(Time.now.to_f-@start.to_f)
          puts "#{client_ip}:#{client_port} #{Time.now.iso8601} \"#{method} #{req}\" #{status} #{response.bytesize} \"#{type}\" #{dur}" if options[:verbose]
          client.close
        rescue Exception =>e
          response="Error '#{e}'"
          status="500"
          type="text/html"
          dur=sprintf "%.2f",(Time.now.to_f-@start.to_f)
          puts "#{client_ip}:#{client_port} #{Time.now.iso8601} \"#{method} #{req}\" #{status} #{response.bytesize} \"#{type}\" #{dur}"
          client.print "HTTP/1.1 #{status} #{statuses[status]||'???'}\r\nContent-Type: #{type}\r\n\r\n"
          client.print response
          client.close
          puts e
          pp e.backtrace
        end
      end
    end
  end
end
