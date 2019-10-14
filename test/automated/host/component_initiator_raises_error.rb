require_relative '../automated_init'

context "Host" do
  context "Component Initiator Raises Error" do
    context "Without Error Recorder" do
      host = Host.new

      host.register Controls::ComponentInitiator::RaisesError

      test "Error is raised" do
        assert_raises Controls::Error::Example do
          host.start
        end
      end
    end

    context "With Error Recorder" do
      host = Host.new

      host.register Controls::ComponentInitiator::RaisesError

      recorded_error = nil
      host.record_error do |err|
        recorded_error = err
      end

      test "Error is raised" do
        assert_raises Controls::Error::Example do
          host.start
        end
      end

      test "Error is recorded" do
        refute recorded_error.nil?
      end
    end
  end
end
