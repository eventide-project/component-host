require_relative '../automated_init'

context "Component Is Registered With Host, Name Is Specified" do
  host = Host.new
  component_initiator = Controls::StartComponent.example

  host.register component_initiator, :other_name

  test "Specified name is used to register component with host" do
    assert host do
      registered? do |_component_initiator, name|
        _component_initiator == component_initiator && name == :other_name
      end
    end
  end
end
