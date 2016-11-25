require_relative '../automated_init'

context "Process Write Dependency" do
  context "Process is instantiated" do
    process = Controls::Process::Example.new

    test "Write dependency is set to substitute" do
      assert process.write do
        instance_of? Actor::Messaging::Write::Substitute
      end
    end
  end

  context "Process is configured" do
    process = Controls::Process::Example.build

    test "Write dependency is configured" do
      assert process.write do
        instance_of? Actor::Messaging::Write
      end
    end
  end
end
