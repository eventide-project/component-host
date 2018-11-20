require_relative '../automated_init'

context "Register Signal Handler" do
  context "Unknown Signal is Registered" do
    register_signal_handler = ComponentHost::Signal::RegisterHandler.new

    signal = Controls::Signal::Unknown.example

    test "Raises error" do
      assert proc { register_signal_handler.(signal) { } } do
        raises_error?(ComponentHost::Signal::RegisterHandler::Error)
      end
    end
  end
end
