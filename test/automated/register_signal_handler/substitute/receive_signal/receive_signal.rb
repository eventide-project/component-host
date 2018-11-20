require_relative '../../../automated_init'

context "Register Signal Handler" do
  context "Substitute" do
    context "Receive Signal" do
      substitute = Dependency::Substitute.build(ComponentHost::Signal::RegisterHandler)

      signal = Controls::Signal.example

      handled_signal_number = nil

      substitute.(signal) do |signal_number|
        handled_signal_number = signal_number
      end

      assert(handled_signal_number.nil?)

      substitute.receive(signal)

      test "Registered signal handler is invoked" do
        refute(handled_signal_number.nil?)
      end

      test "Signal number is supplied to block" do
        signal_number = Controls::Signal::Number.example(signal)

        assert(handled_signal_number = signal_number)
      end
    end
  end
end
