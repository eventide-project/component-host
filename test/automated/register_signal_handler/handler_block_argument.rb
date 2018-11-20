require_relative '../automated_init'

context "Register Signal Handler" do
  context "Handler Block Argument" do
    register_signal_handler = ComponentHost::Signal::RegisterHandler.new

    signal = Controls::Signal.example

    block_argument = nil

    register_signal_handler.(signal) do |argument|
      block_argument = argument
    end

    context "Process is sent signal" do
      Controls::Signal::Send.()

      test "Signal number is supplied to handler" do
        signal_number = Controls::Signal::Number.example(signal)

        assert(block_argument == signal_number)
      end
    end
  end
end
