require_relative '../automated_init'

context "Component Is Registered With Host" do
  host = Host.new
  component_initiator = Controls::StartComponent.example

  host.register component_initiator

  test "Sart procedure is registered" do
    assert host do
      registered? do |_component_initiator|
        _component_initiator == component_initiator
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
