require_relative './interactive_init'

ComponentHost.start 'interactive-test' do |host|
  host.register Controls::StartComponent::RunsContinuously
end
