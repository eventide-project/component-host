class ProcessHost
  module Controls
    class ExampleServer
      attr_reader :connections
      attr_reader :max_per_connection

      dependency :logger, Telemetry::Logger

      def initialize max_per_connection
        @connections = max_per_connection
        @max_per_connection = max_per_connection
      end

      def self.build(max_per_connection)
        instance = new max_per_connection
        Telemetry::Logger.configure instance
        instance
      end

      def start
        loop do
          builder = ::HTTP::Protocol::Request.builder
          logger.trace "Server is reading request headers"
          builder << client_connection.gets until builder.finished_headers?
          logger.debug "Server has read request headers"

          request = builder.message
          logger.data "Request headers:\n#{request}"

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

          logger.trace "Server is writing response headers"
          logger.data "Response headers:\n#{response}"
          response.to_s.each_line do |line|
            client_connection.puts line
          end
          logger.debug "Server has written response headers"
          logger.trace "Server is writing response body"
          logger.debug "Response body:\n#{data}"
          client_connection.write data
          logger.debug "Server has written response body"

          if close_connection
            client_connection.close
            @client_connection = nil
            logger.debug "Server has reset client connection"
          end

          raise StopIteration if new_count.zero?
        end
      end

      def server_connection
        @server_connection ||= Connection::Server.build "127.0.0.1", 90210
      end

      def client_connection
        @client_connection ||= server_connection.accept
      end

      def consume_use
        @connections -= 1
        return connections
      ensure
        @connections = max_per_connection if connections.zero?
      end

      module Process
        def run(&blk)
          blk.(server_connection)
          start
        end
      end
    end
  end
end
