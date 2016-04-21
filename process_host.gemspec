Gem::Specification.new do |s|
  s.name        = 'process_host'
  s.version     = '0.0.3.1'
  s.summary     = 'Run multiple logical processes inside a single physical process.'
  s.description = 'Turns your ruby program into a long running process that your init system can manage.'

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/obsidian-btc/process-host'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.3'

  s.add_runtime_dependency 'telemetry-logger'
  s.add_runtime_dependency 'connection-client'
  s.add_runtime_dependency 'connection-server'

  s.add_development_dependency 'http-protocol'
  s.add_development_dependency 'test_bench'
end
