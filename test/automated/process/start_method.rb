require_relative '../automated_init'

context "Process Start Method" do
  context "Specialized method is implemented by including class" do
    process = Controls::Process.example

    return_value = process.start

    test "Specialized method is executed" do
      assert process do
        started?
      end
    end

    test "Methods cannot be called on return value" do
      assert proc { return_value.some_method } do
        raises_error? AsyncInvocation::Incorrect::Error
      end
    end
  end

  context "Specialized method is not implemented by including class" do
    cls = Class.new do
      include ProcessHost::Process
    end

    process = cls.new

    test "Abstract method error is raised" do
      assert proc { process.start } do
        raises_error? Virtual::PureMethodError
      end
    end
  end
end
