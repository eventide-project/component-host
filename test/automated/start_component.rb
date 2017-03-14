require_relative './automated_init'

context "Starting Component" do
  component_name = Controls::ComponentName.example

  started_processes = ComponentHost.start component_name do
    register Controls::Process::StopsImmediately, 'process-1'
    register Controls::Process::StopsImmediately, 'process-2'
  end

  test "Registered processes are started" do
    assert started_processes[0] do
      instance_of? Controls::Process::StopsImmediately
    end

    assert started_processes[1] do
      instance_of? Controls::Process::StopsImmediately
    end
  end
end
