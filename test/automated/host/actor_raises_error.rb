require_relative '../automated_init'

context "Host" do
  context "Actor Raises Error" do
    context "Without Error Recorder" do
      host = Host.new

      host.register Controls::ComponentInitiator::ActorCrashes

      test "Error is raised" do
        assert proc { host.start } do
          raises_error? Controls::Error::Example
        end
      end
    end

    context "With Error Recorder" do
      host = Host.new

      host.register Controls::ComponentInitiator::ActorCrashes

      recorded_error = nil
      host.record_error do |err|
        recorded_error = err
      end

      test "Error is raised" do
        assert proc { host.start } do
          raises_error? Controls::Error::Example
        end
      end

      test "Error is recorded" do
        refute recorded_error.nil?
      end
    end
  end
end
