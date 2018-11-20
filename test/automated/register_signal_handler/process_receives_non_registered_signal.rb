require_relative '../automated_init'

context "Register Signal Handler" do
  context "Process Receives Non Registered Signal" do
    register_signal_handler = ComponentHost::Signal::RegisterHandler.new

    registered_signal = Controls::Signal.example
    received_signal = Controls::Signal.alternate

    handled_signal = false

    register_signal_handler.(registered_signal) do
      handled_signal = true
    end

    Controls::Signal::Send.(received_signal)

    test "Signal is not handled" do
      refute(handled_signal)
    end
  end
end
