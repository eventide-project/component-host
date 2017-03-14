require_relative '../automated_init'

context "Component Is Registered With Host" do
  host = Host.new
  start_proc = Controls::StartComponent.example

  host.register start_proc

  test "Sart procedure is registered" do
    assert host do
      registered? do |_start_proc|
        _start_proc == start_proc
      end
    end
  end

  test "Name is not set" do
    assert host do
      registered? do |_, name|
        name == nil
      end
    end
  end
end
