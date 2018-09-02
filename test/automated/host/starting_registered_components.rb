require_relative '../automated_init'

context "Host Starts Registered Components" do
  host = Host.new

  host.register Controls::StartComponent.example, 'component-1'
  host.register Controls::StartComponent.example, 'component-2'

  context "Host is started" do
    components = host.start do
      raise StopIteration
    end

    components.each_with_index do |component, index|
      context "Component ##{index + 1}" do
        test "Is started" do
          assert component.component_initiator do
            executed?
          end
        end

        test "Name is set" do
          assert component.name == "component-#{index + 1}"
        end
      end
    end
  end
end
