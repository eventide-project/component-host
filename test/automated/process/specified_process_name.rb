require_relative '../automated_init'

context "Specified Process Name" do
  process_class = Class.new do
    include ComponentHost::Process

    process_name :some_process
  end

  context "Process name is queried" do
    process_name = process_class.process_name

    test "Specfied value is returned" do
      assert process_name == :some_process
    end
  end
end
