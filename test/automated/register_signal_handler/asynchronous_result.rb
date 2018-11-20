require_relative '../automated_init'

context "Register Signal Handler" do
  context "Asynchronous Result" do
    register_signal_handler = ComponentHost::Signal::RegisterHandler.new

    signal = Controls::Signal.example

    res = register_signal_handler.(signal) { }

    test "Returns a result that fails if actuated" do
      assert(res == AsyncInvocation::Incorrect)
    end
  end
end
