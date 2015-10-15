Gem::Specification.new do |s|
  s.name        = "process_host"
  s.version     = "0.1.0"
  s.licenses    = ["MIT"]
  s.summary     = "Run multiple logical processes inside a single physical process."
  s.description = "Run multiple logical processes inside a single physical process. Turns your ruby program into a long running process that your init system can manage."
  s.authors     = ["Nathan Ladd"]
  s.email       = "nathanladd+github@gmail.com"
  s.files       = Dir["lib/**/*.rb"]
  s.homepage    = "https://github.com/obsidian-btc/process-host"
  s.executables = []

  s.add_runtime_dependency 'telemetry-logger'
  s.add_runtime_dependency 'connection'
end
