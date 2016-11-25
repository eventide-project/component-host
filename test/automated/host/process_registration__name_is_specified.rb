require_relative '../automated_init'

context "Process Is Registered With Host, Name Is Specified" do
  host = Host.new
  process_class = Controls::Process::Example

  process_name = host.register process_class, :other_name

  test "Specified process name is returned" do
    assert process_name == :other_name
  end

  test "Specified name is used to register process with host" do
    assert host do
      registered? do |cls, name|
        cls == process_class && name == :other_name
      end
    end
  end
end
