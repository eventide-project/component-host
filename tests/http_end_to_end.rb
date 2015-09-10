require "ftest/script"
require "process_host"

require "http/protocol"
require "socket"
require 'timeout'

class Server
  attr_reader :connections
  attr_reader :max_per_connection

  def initialize max_per_connection
    @connections = max_per_connection
    @max_per_connection = max_per_connection
  end

  def connect io
    io.socket = tcp_server.accept_nonblock
  rescue IO::WaitReadable, Errno::EINTR
  end

  def start io
    loop do
      builder = HTTP::Protocol::Request.builder
      builder << io.gets until builder.finished_headers?

      request = builder.message

      path = request.path
      match = path.match %r{^/test-pattern/(?<count>\d+)$}

      count = match.to_a.fetch 1
      new_count = count.to_i - 1

      data = "#{new_count}\r\n"
      response = HTTP::Protocol::Response.new 200, "OK"
      response["Content-Length"] = data.size

      conn_count = consume_use
      close_connection = conn_count.zero?

      if close_connection
        response["Connection"] = "close"
      else
        response["Connection"] = "keep-alive"
        response["Keep-Alive"] = "max=#{conn_count},timeout=120"
      end

      response.to_s.each_line do |line|
        io.puts line
      end
      io.write data
      io.close if close_connection

      raise StopIteration if new_count.zero?
    end
  end

  private

  def consume_use
    @connections -= 1
    return connections
  ensure
    @connections = max_per_connection if connections.zero?
  end

  def tcp_server
    @tcp_server ||= TCPServer.new 9999
  end
end

class Client
  attr_reader :count
  attr_reader :socket

  def initialize count
    @count = count
  end

  def connect io
    io.socket = TCPSocket.new "127.0.0.1", 9999
  end

  def start io
    loop do
      request = HTTP::Protocol::Request.new "GET", "/test-pattern/#{count}"
      request["Host"] = "localhost"
      io.write request

      builder = HTTP::Protocol::Response.builder
      builder << io.gets until builder.finished_headers?

      response = builder.message
      content_length = response["Content-Length"].to_i

      data = io.read content_length
      @count = data.to_i
      logger.info do "Count is now #{count}; Connection=#{response["Connection"]}" end
      io.close if response["Connection"] == "close"

      raise StopIteration if count.zero?
    end
  end
end

# Test iterates n times
requests = 100
# Persist connections n times before closing connection
max_per_connection = 50

process_host = ProcessHost.build do |config|
  config.logger = logger
  config.poll_period_ms = 0
end

t0 = Time.now

at_exit do
  assert $client, :kind_of => Client
  assert $client.count, :equals => 0
end

logger.info "Running process"
begin

  process_host.run do
    $client = Client.new requests
    $server = Server.new max_per_connection

    add "http-client", $client
    add "http-server", $server
  end

rescue StopIteration
  time = Time.now - t0

  ms = (time * 1000).round
  rps = Rational(requests, time).to_i
  rpm = rps * 60

  puts "Client finished processing #{requests} requests in (#{ms}ms, #{rps}rps, #{rpm}rpm)"
end
