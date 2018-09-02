Gem::Specification.new do |s|
  s.name = 'evt-component_host'
  s.version = '0.2.0.9'
  s.summary = 'Host components inside a single physical process'
  s.description = ' '

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/eventide-project/component-host'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.4'

  s.add_runtime_dependency 'ntl-actor'

  s.add_runtime_dependency 'evt-async_invocation'
  s.add_runtime_dependency 'evt-casing'
  s.add_runtime_dependency 'evt-log'
  s.add_runtime_dependency 'evt-virtual'

  s.add_development_dependency 'test_bench'
end
