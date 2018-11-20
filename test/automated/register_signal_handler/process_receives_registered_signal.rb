require_relative '../automated_init'

context "Register Signal Handler" do
  context "Process Receives Registered Signal" do
    register_signal_handler = ComponentHost::Signal::RegisterHandler.new

    signal = Controls::Signal.example

    handled_signal = false

    register_signal_handler.(signal) do
      handled_signal = true
    end

    Controls::Signal::Send.(signal)

    test "Signal is handled" do
      assert(handled_signal)
    end
  end
end
