require_relative '../../automated_init'

context "Host" do
  context "Component Registration" do
    context "Optional Name" do
      component_initiator = Controls::StartComponent.example

      context "Name is Specified" do
        host = Host.new

        control_name = Controls::Name.example

        host.register component_initiator, control_name

        test "Name is registered with the host" do
          assert host do
            registered? do |_, name|
              name == control_name
            end
          end
        end
      end

      context "Name is Not Specified" do
        host = Host.new

        host.register component_initiator

        test "Name is not registered with the host" do
          assert host do
            registered? do |_, name|
              name.nil?
            end
          end
        end
      end
    end
  end
end
