require_relative '../automated_init'

context "Process Name" do
  context do
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

  context "Class is nested within namespaces" do
    process_class = Class.new do
      include ProcessHost::Process

      def self.name
        'SomeNamespace::OtherNamespace::Process'
      end
    end

    name = process_class.process_name

    test "Namespaces preceding the innermost are discarded" do
      assert name == :process
    end
  end
end
