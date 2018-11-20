require_relative '../../../automated_init'

context "Register Signal Handler" do
  context "Substitute" do
    context "Receive Signal" do
      context "Unknown Signal" do
        substitute = Dependency::Substitute.build(ComponentHost::Signal::RegisterHandler)

        signal = Controls::Signal::Unknown.example

        test "Raises error" do
          assert proc { substitute.receive(signal) } do
            raises_error?(ComponentHost::Signal::RegisterHandler::Error)
          end
        end
      end
    end
  end
end
