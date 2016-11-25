require_relative '../automated_init'

context "Default Process Name" do
  context "Process name is queried" do
    process_class = Class.new do
      include ProcessHost::Process

      def self.name
        'SomeProcess'
      end
    end

    name = process_class.process_name

    test "Class constant name is converted to an underscore cased symbol" do
      assert name == :some_process
    end
  end

  context "Class is anonymous" do
    process_class = Class.new do
      include ProcessHost::Process
    end

    context "Process name is queried" do
      name = process_class.process_name

      test "Value returned indicates process name is unknown" do
        assert name == :unknown
      end
    end
  end

  context "Class is nested within namespaces" do
    process_class = Class.new do
      include ProcessHost::Process

      def self.name
        'SomeNamespace::OtherNamespace::Process'
      end
    end

    context "Process name is queried" do
      name = process_class.process_name

      test "Namespaces preceding the innermost are discarded" do
        assert name == :process
      end
    end
  end
end
