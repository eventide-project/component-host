require_relative '../../automated_init'

context "Register Signal Handler" do
  context "Substitute" do
    context "Registered Predicate" do
      substitute = Dependency::Substitute.build(ComponentHost::Signal::RegisterHandler)

      signal = Controls::Signal.example

      substitute.(signal) { }

      context "Given the signal that was registered" do
        test "Returns true" do
          assert(substitute.registered?(signal))
        end
      end

      context "Given a signal that was not registered" do
        other_signal = Controls::Signal.alternate

        test "Returns false" do
          refute(substitute.registered?(other_signal))
        end
      end
    end
  end
end
