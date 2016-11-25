require_relative '../automated_init'

context "Process Is Registered With Host" do
  host = Host.new
  process_class = Controls::Process::Example

  host.register process_class

  test "Process is registered with host" do
    assert host do
      registered? do |cls, name|
        cls == process_class && name == Controls::Process::Name.example
      end
    end
  end

  test "Process class is not instantiated" do
    instances = ObjectSpace.each_object process_class

    assert instances.none?
  end
end
