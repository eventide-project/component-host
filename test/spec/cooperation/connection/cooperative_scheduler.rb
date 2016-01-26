require_relative './connection_spec_init'

require 'connection/controls'

context 'Cooperative Scheduler' do
  octet = Connection::Controls::IO::Octet.example
  dispatcher = ProcessHost::Controls::Cooperation::Dispatcher.new
  write_buffer_window_size = Connection::Controls::IO::Scenarios::WritesWillBlock.write_buffer_window_size

  scheduler = ProcessHost::Cooperation::Connection::Scheduler::Cooperative.build dispatcher

  test 'Scheduling a read' do
    Connection::Controls::IO::Scenarios::ReadsWillBlock.activate do |read_io, write_io|
      dispatcher.expect_read read_io do
        write_io.write octet
      end

      fiber = Fiber.new do
        scheduler.wait_readable read_io
      end.tap &:resume

      assert dispatcher.verify

      assert read_io, Connection::Controls::UNIXSocket::Assertions do
        !read_would_block?
      end
    end
  end

  test 'Scheduling a write' do
    Connection::Controls::IO::Scenarios::WritesWillBlock.activate do |read_io, write_io|
      dispatcher.expect_write write_io do
        read_io.read write_buffer_window_size
      end

      fiber = Fiber.new do
        scheduler.wait_writable write_io
      end.tap &:resume

      assert dispatcher.verify

      assert write_io, Connection::Controls::UNIXSocket::Assertions do
        !write_would_block?
      end
    end
  end
end
