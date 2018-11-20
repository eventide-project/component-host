require_relative '../../automated_init'

context "Register Signal Handler" do
  context "Substitute" do
    context "Unknown Signal is Registered" do
      substitute = Dependency::Substitute.build(ComponentHost::Signal::RegisterHandler)

      signal = Controls::Signal::Unknown.example

      test "Raises error" do
        assert proc { substitute.(signal) { } } do
          raises_error?(ComponentHost::Signal::RegisterHandler::Error)
        end
      end
    end
  end
end
