module ProcessHost
  module Controls
    class ExampleServer
      attr_reader :keepalive_max

      dependency :logger, Telemetry::Logger

      def initialize(keepalive_max)
        @keepalive_max = keepalive_max
      end

      def self.build
        keepalive_max = ENV["EXAMPLE_SERVER_KEEPALIVE_MAX"] || "50"
        instance = new keepalive_max.to_i
        Telemetry::Logger.configure instance
        instance
      end

      def start
        running = true

        while running
          logger.trace 'Server acceping client'
          client_connection = server_connection.accept
          logger.debug 'Server accepted client'

          keepalive_max.times.to_a.reverse.each do |keepalive_left|
            builder = ::HTTP::Protocol::Request::Builder.build
            logger.trace 'Server is reading request headers'
            builder << client_connection.readline("\r\n") until builder.finished_headers?
            logger.debug 'Server has read request headers'

            request = builder.message
            logger.data "Request headers:\n#{request}"

            path = request.path
            match = path.match %r{^/test-pattern/(?<count>\d+)$}

            count = match.to_a.fetch 1
            new_count = count.to_i - 1

            data = "#{new_count}\r\n"
            response = HTTP::Protocol::Response.new 200, "OK"
            response['Content-Length'] = data.size

            if keepalive_left.zero?
              response['Connection'] = 'close'
            else
              response['Connection'] = 'keep-alive'
              response['Keep-Alive'] = "max=#{keepalive_left},timeout=120"
            end

            logger.trace 'Server is writing response headers'
            logger.data "Response headers:\n#{response}"
            response.to_s.each_line do |line|
              client_connection.write line
            end
            logger.debug 'Server has written response headers'
            logger.trace 'Server is writing response body'
            logger.data "Response body:\n#{data}"
            client_connection.write data
            logger.debug 'Server has written response body'

            if keepalive_left.zero?
              client_connection.close
              logger.debug 'Server has reset client connection'
            end

            if new_count == 0
              running = false
              break
            end
          end
        end
      end

      def server_connection
        @server_connection ||= Connection.server 90210
      end

      module ProcessHostIntegration
        def change_connection_scheduler(scheduler)
          server_connection.scheduler = scheduler
        end
      end
    end
  end
end
