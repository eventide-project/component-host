require_relative '../../automated_init'

context "Host" do
  context "Component Registration" do
    host = Host.new
    component_initiator = Controls::ComponentInitiator.example

    host.register component_initiator

    test "Component initiator is registered" do
      registered = host.registered? do |initiator|
        initiator == component_initiator
      end

      assert(registered)
    end

    test "Name is not set" do
      registered = host.registered? do |_, name|
        name == nil
      end

      assert(registered)
    end
  end
end
