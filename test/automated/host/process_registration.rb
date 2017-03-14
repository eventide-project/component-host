require_relative '../automated_init'

context "Process Is Registered With Host" do
  host = Host.new
  process_class = Controls::Process::Example

  return_value = host.register process_class

  test "Process name of process class is returned" do
    assert return_value == Controls::Process::Name.example
  end

  test "Process is registered with host" do
    assert host do
      registered? do |cls, name|
        cls == process_class && name == Controls::Process::Name.example
      end
    end
  end
end
