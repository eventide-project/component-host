require_relative '../automated_init'

context "Host Starts Registered Processes" do
  host = Host.new

  host.register Controls::Process::Example, 'process-1'
  host.register Controls::Process::Example, 'process-2'

  context "Host is started" do
    processes = host.start do
      raise StopIteration
    end

    processes.each_with_index do |process, index|
      context "Process ##{index + 1}" do
        test "Process class is constructed" do
          assert process do
            instance_of? Controls::Process::Example
          end
        end

        test "Write dependency is configured" do
          assert process.write do
            instance_of? Actor::Messaging::Write
          end
        end

        test "Process is started" do
          assert process do
            started?
          end
        end
      end
    end
  end
end
