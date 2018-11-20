require_relative '../../../automated_init'

context "Register Signal Handler" do
  context "Substitute" do
    context "Receive Signal" do
      context "Non Registered Signal" do
        substitute = Dependency::Substitute.build(ComponentHost::Signal::RegisterHandler)

        registered_signal = Controls::Signal.example
        received_signal = Controls::Signal.alternate

        handled_signal = false

        substitute.(registered_signal) do
          handled_signal = true
        end

        substitute.receive(received_signal)

        test "Signal is not handled" do
          refute(handled_signal)
        end
      end
    end
  end
end
