require "ftest/script"
require "process_host"

require "socket"

class Server
  def connect
    client_socket = tcp_server.accept_nonblock
  rescue IO::WaitReadable, Errno::EINTR
  ensure
    return client_socket
  end

  def prepare_socket socket
    fail "Should not even try"
  end

  private

  def tcp_server
    TCPServer.new 90210
  end
end

process_host = ProcessHost.new logger, poll_period: 0.5
process_host.add Server.new
process_host.run 1
