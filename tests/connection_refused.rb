require "ftest/script"
require "process_host"

require "socket"

class Server
  def connect io
    socket = TCPSocket.new "127.0.0.1", 90210
    io.connect socket
  end

  def next! io
    fail "Should not even try"
  end
end

process_host = ProcessHost.build do |config|
  config.logger = logger
  config.poll_period_ms = 0.5
end

process_host.run 1 do
  add "connection-refused-server", Server.new
end
