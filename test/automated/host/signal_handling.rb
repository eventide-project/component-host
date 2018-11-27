require_relative '../automated_init'

context "Host" do
  context "Signal Handling" do
    context "TERM" do
      supervisor_address = nil

      host = Host.new
      host.start do |supervisor|
        supervisor_address = supervisor.address
        host.abort
      end

      host.signal.send 'TERM'

      test "Shutdown message is sent to supervisor" do
        assert host.send do
          sent? :shutdown, address: supervisor_address
        end
      end
    end

    context "TSTP (ctrl+Z)" do
      supervisor_address = nil

      host = Host.new
      host.start do |supervisor|
        supervisor_address = supervisor.address
        host.abort
      end

      host.signal.send 'TSTP'

      test "Suspend message is sent to supervisor" do
        assert host.send do
          sent? :suspend, address: supervisor_address
        end
      end
    end

    context "CONT" do
      supervisor_address = nil

      host = Host.new
      host.start do |supervisor|
        supervisor_address = supervisor.address
        host.abort
      end

      host.signal.send 'CONT'

      test "Resume message is sent to supervisor" do
        assert host.send do
          sent? :resume, address: supervisor_address
        end
      end
    end

    context "INT" do
      supervisor_address = nil

      host = Host.new
      host.start do |supervisor|
        supervisor_address = supervisor.address
        host.abort
      end

      host.signal.send 'INT'

      test "Shutdown message is sent to supervisor" do
        assert host.send do
          sent? :shutdown, address: supervisor_address
        end
      end
    end
  end
end
