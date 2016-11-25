require_relative '../automated_init'

context "Signal Dependency is Configured" do
  receiver = OpenStruct.new

  context "Attribute name is not specified" do
    ProcessHost::Signal.configure receiver

    test "Signal attribute is configured" do
      assert receiver.signal == ::Signal
    end
  end

  context "Attribute name is specified" do
    ProcessHost::Signal.configure receiver, attr_name: :some_attr

    test "Attribute is configured" do
      assert receiver.some_attr == ::Signal
    end
  end
end
