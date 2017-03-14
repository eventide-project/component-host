require_relative './automated_init'

context "Starting Host" do
  process_name = Controls::ProcessName.example

  started_components = ComponentHost.start process_name do
    register Controls::StartComponent::StopsImmediately, 'component-1'
    register Controls::StartComponent::StopsImmediately, 'component-2'
  end

  test "Registered components are started" do
    assert started_components[0].name == 'component-1'
    assert started_components[1].name == 'component-2'
  end
end
