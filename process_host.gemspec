Gem::Specification.new do |s|
  s.name = 'process_host'
  s.version = '0.4.0.0'
  s.summary = 'Run multiple logical processes inside a single physical process'
  s.description = ' '

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/eventide-project/process-host'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.3'

  s.add_runtime_dependency 'async_invocation'
  s.add_runtime_dependency 'casing'
  s.add_runtime_dependency 'log'
  s.add_runtime_dependency 'ntl-actor'
  s.add_runtime_dependency 'virtual'

  s.add_development_dependency 'test_bench'
end
