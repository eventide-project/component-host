require_relative '../automated_init'

context "Multiple Processes Are Registered With Identical Names" do
  host = Host.new

  host.register Controls::Process::Example

  other_process_class = Class.new do
    include ComponentHost::Process

    process_name Controls::Process::Name.example
  end

  context "Second process is registered" do
    test "Name conflict error is raised" do
      assert proc { host.register other_process_class } do
        raises_error? Host::NameConflictError
      end
    end
  end
end
