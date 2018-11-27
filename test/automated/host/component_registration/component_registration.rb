require_relative '../../automated_init'

context "Host" do
  context "Component Registration" do
    host = Host.new
    component_initiator = Controls::ComponentInitiator.example

    host.register component_initiator

    test "Component initiator is registered" do
      assert host do
        registered? do |initiator|
          initiator == component_initiator
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
end
