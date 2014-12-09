minimal-http-ruby
=================

Minimal Http Server Class with Ryby: Haml &amp; Coffeescript &amp; SSE &amp; AJAX -- well under 200 lines of code!

The server will run it it's own thread, without messing your code any extra EventMachine -style dependencies.

You can easily access realtime data with AJAX and SSE -- they will see your main application's global variables.

Great for adding HTTP-debug page to any small app, with the luxory of Coffeescript & Haml.

## Note!!
Please, do not serve pages to internets with this server -- ABSOLUTELY NO SECURITY!

## Usage
This is simple: just check the example! Like this:

``` ruby
require 'minimal-http-ruby'

minimal_http_server http_port: 8088, http_path: "./http/"

loop do #or whatever you need to do
	sleep 1
end
```

##Conventions:
Static files are cached, so do not serve gigantic pictures.  Next examples assume that your :http_path is "http/"

- Use **Coffeescript** :) Place .coffee files in ```http/coffee``` and any .js file requested is compiled from your source. Cached for performace.

- Use **Haml !** Place .haml files in ```http/haml``` and any .http file requested is compiled from your source. Not cached as dynamic content.

- Use **AJAX** :  When you access .json file from your page, the server tries to find
``` ruby
# encode: UTF-8

def json_demo request,args,session,event
  data = { now:Time.now.to_i }
  return ["application/json",data]
end
```

- Use **SSE** :  This goes like AJAX, but instead of returning "application/json", you should specify: "text/event-stream" -- the server knows now to keep this stream open. You can make your script sleep for few seconds, that will be the Event Period -- the server sleeps one extra second for safety. Example here:

``` ruby
# encode: UTF-8

def json_demo request,args,session,event
  if not session or session==0
    return ["text/event-stream",{}]
  end
  sleep 10
  data={
    now:Time.now.to_i,
  }
  return ["text/event-stream",data]
end
```
And it's result on browser:
``` asciidoc
retry: 1000
data: {"now":1417014637}

retry: 1000
data: {"now":1417014641}

retry: 1000
data: {"now":1417014645}

retry: 1000
data: {"now":1417014649}
```

### Initialization:

To get started, you can run utility ```minimal-http-init.rb``` -- It will create all directories and initial index.haml in your current directory!

##Coming Next:
- better cache control
- factoring source
- cleanup
- make class? not really necessary
