require_relative '../automated_init'

context "Error Is Raised" do
  error = Controls::Error.example

  context "No error recorder is specified" do
    host = Host.new

    start_proc = proc {
      host.start do
        raise error
      end
    }

    test "Error is not suppressed" do
      assert start_proc do
        raises_error? Controls::Error::Example
      end
    end
  end

  context "Error recorder is specified" do
    recorded_error = nil

    host = Host.new
    host.record_error do |err|
      recorded_error = err
    end

    start_proc = proc {
      host.start do
        raise error
      end
    }

    test "Error is not suppressed" do
      assert start_proc do
        raises_error? Controls::Error::Example
      end
    end

    test "Error recorder is actuated and supplied the error that was raised" do
      assert recorded_error == error
    end
  end
end
