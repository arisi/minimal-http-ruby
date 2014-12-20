Gem::Specification.new do |s|
  s.name        = 'minimal-http-ruby'
  s.version     = '0.0.11'
  s.date        = '2014-12-20'
  s.summary     = "Minimal Http Threaded Server Coffeescript,Ajax,Haml,SSE"
  s.description = "Minimal Http Threaded Server with Ryby: Haml, Coffeescript, SSE, AJAX -- well under 200 lines of code!"
  s.authors     = ["Ari Siitonen"]
  s.email       = 'jalopuuverstas@gmail.com'
  s.files       = ["lib/minimal-http-ruby.rb", "examples/server.rb"]
  s.files      += Dir['http/**/*']
  s.homepage    = 'https://github.com/arisi/minimal-http-ruby'
  s.license     = 'MIT'
  s.add_runtime_dependency "haml", '~> 4.0', '>= 4.0.5'
  s.add_runtime_dependency "coffee-script", '~> 2.3', '>= 2.3.0'
  s.executables << 'minimal-http-init.rb'
  s.executables << 'minimal-http.rb'
end
