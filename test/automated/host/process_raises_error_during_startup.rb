require_relative '../automated_init'

context "Error Is Raised By Process During Startup" do
  context "No error recorder is specified" do
    host = Host.new
    host.register Controls::Process::RaisesError

    test "Error is not suppressed" do
      assert proc { host.start } do
        raises_error? Controls::Error::Example
      end
    end
  end

  context "Error recorder is specified" do
    recorded_error = nil

    host = Host.new
    host.register Controls::Process::RaisesError

    host.record_error do |err|
      recorded_error = err
    end

    test "Error is not suppressed" do
      assert proc { host.start } do
        raises_error? Controls::Error::Example
      end
    end

    test "Error recorder is actuated and supplied the error that was raised" do
      assert recorded_error == Controls::Process::RaisesError.error
    end
  end
end
