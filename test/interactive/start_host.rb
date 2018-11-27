require_relative './interactive_init'

name = Controls::Name.example

ComponentHost.start 'interactive-test' do |host|
  host.register Controls::ComponentInitiator::RunsContinuously, name
end
