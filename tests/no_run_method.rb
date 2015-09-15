require_relative "./tests_init"

module NoRunMethod
end

process_host = ProcessHost.build
assert :raises => ProcessHost::InvalidProcess do
  process_host.register NoRunMethod
end
