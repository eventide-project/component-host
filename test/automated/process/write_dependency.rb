require_relative '../automated_init'

context "Process Write Dependency" do
  context "Process is instantiated" do
    process = Controls::Process::Example.new

    test "Send dependency is set to substitute" do
      assert process.send do
        instance_of? Actor::Messaging::Send::Substitute
      end
    end
  end

  context "Process is configured" do
    process = Controls::Process::Example.build

    test "Send dependency is configured" do
      assert process.send do
        instance_of? Actor::Messaging::Send
      end
    end
  end
end
