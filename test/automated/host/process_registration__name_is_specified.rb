require_relative '../automated_init'

context "Component Is Registered With Host, Name Is Specified" do
  host = Host.new
  start_proc = Controls::StartComponent.example

  host.register start_proc, :other_name

  test "Specified name is used to register component with host" do
    assert host do
      registered? do |_start_proc, name|
        _start_proc == start_proc && name == :other_name
      end
    end
  end
end
