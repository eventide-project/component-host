require "ftest/script"
require "process_host"

require "http/protocol"
require "socket"

class Server
  attr_reader :persistent_connections

  def initialize max_per_connection
    @persistent_connections = Hash.new max_per_connection
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

  private

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
  rescue Errno::ECONNREFUSED
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
    logger.info do "Count is now #{count}; Connection=#{response["Connection"]}" end
    socket.close if response["Connection"] == "close"

    raise StopIteration if count.zero?
  end
end

# Test iterates n times
requests = 1000
# Persist connections n times before closing connection
max_per_connection = 333

client = Client.new requests
server = Server.new max_per_connection

process_host = ProcessHost.build do |config|
  config.logger = logger
  config.poll_period_ms = 0
end
process_host.add client, "http-client"
process_host.add server, "http-server"

t0 = Time.now

at_exit do
  assert client.count, :equals => 0
end

logger.info "Running process"
begin
  process_host.run
rescue StopIteration
  time = Time.now - t0

  ms = (time * 1000).round
  rps = Rational(requests, time).to_i
  rpm = rps * 60

  puts "Client finished processing #{requests} requests in (#{ms}ms, #{rps}rps, #{rpm}rpm)"
end
