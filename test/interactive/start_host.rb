require_relative './interactive_init'

ProcessHost.start 'interactive-test' do |host|
  host.register Controls::Process::RunsContinuously
end
