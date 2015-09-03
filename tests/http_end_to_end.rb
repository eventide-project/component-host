require "ftest/script"

require "socket"
require "timeout"
require "process_host"
require "http/protocol"

class Server
  attr_reader :persistent_connections

  def initialize reuse_connections
    @persistent_connections = Hash.new do |hsh, fileno|
      hsh[fileno] = reuse_connections
    end
  end

  def connect
    client_socket = tcp_server.accept_nonblock
  rescue IO::WaitReadable, Errno::EINTR
  ensure
    return client_socket
  end

  def receive_socket socket
    builder = HTTP::Protocol::Request.builder
    builder << socket.gets until builder.finished_headers?

    request = builder.message

    path = request.path
    match = path.match %r{^/test-pattern/(?<count>\d+)$}

    fail "invalid path #{path}" unless match
    count = match.to_a.fetch 1

    data = "#{count.to_i - 1}\r\n"
    response = HTTP::Protocol::Response.new 200, "OK"
    response["Content-Length"] = data.size

    conn_count = consume_use socket

    if conn_count.zero?
      response["Connection"] = "close"
    else
      response["Connection"] = "keep-alive"
      response["Keep-Alive"] = "max=#{conn_count},timeout=120"
    end

    socket.write response
    socket.write data
    socket.close if conn_count.zero?
  end

  def consume_use socket
    persistent_connections[socket.fileno] -= 1
    max = persistent_connections[socket.fileno]
    persistent_connections.delete socket.fileno if max.zero?
    max
  end

  def tcp_server
    @tcp_server ||= TCPServer.new 9999
  end
end

class Client
  attr_reader :count

  def initialize count
    @count = count
  end

  def connect
    TCPSocket.new "127.0.0.1", 9999
  end

  def prepare_socket socket
    request = HTTP::Protocol::Request.new "GET", "/test-pattern/#{count}"
    request["Host"] = "localhost"
    socket.write request
  end

  def receive_socket socket
    builder = HTTP::Protocol::Response.builder
    builder << socket.gets until builder.finished_headers?

    response = builder.message
    content_length = response["Content-Length"].to_i

    data = socket.read content_length
    @count = data.to_i
    logger.info "Count is now #{count}; Connection=#{response["Connection"]}"
    socket.close if response["Connection"] == "close"

    raise StopIteration if count.zero?
  end
end

# Test iterates n times
client = Client.new 200
# Persist connections n times before closing connection
server = Server.new 50

process_host = ProcessHost.new logger, 0
process_host.add server
process_host.add client

Timeout.timeout 2 do
  begin
    process_host.run
  rescue StopIteration
    logger.info "Client raised StopIteration, the test is finished"
  end
end

assert client.count, :equals => 0
