module ProcessHost
  module Controls
    class ExampleClient
      attr_reader :count
      attr_reader :socket

      dependency :logger, Telemetry::Logger

      def initialize(count)
        @count = count
      end

      def self.build
        count = ENV["EXAMPLE_CLIENT_COUNT"] || "5"
        instance = new count.to_i
        Telemetry::Logger.configure instance
        instance
      end

      def start
        while count > 0
          request = HTTP::Protocol::Request.new "GET", "/test-pattern/#{count}"
          request["Host"] = "localhost"
          logger.opt_trace "Client is writing request headers"
          logger.opt_data "Request headers:\n#{request}"
          connection.write request.to_s
          logger.opt_debug "Client has written request headers"

          builder = HTTP::Protocol::Response::Builder.build
          logger.opt_trace "Client is reading response headers"
          builder << connection.readline("\r\n") until builder.finished_headers?
          logger.opt_debug "Client has read response headers"

          response = builder.message
          logger.opt_data "Response headers:\n#{response}"
          content_length = response["Content-Length"].to_i

          logger.opt_trace "Client is reading response body"
          data = connection.read content_length
          logger.opt_debug "Client has read response body"
          logger.opt_data "Response body:\n#{data}"

          @count = data.to_i
          logger.info "Count is now #{count}; Connection=#{response["Connection"]}"
          connection.close if response["Connection"] == "close"
        end
      end

      def connection
        @connection ||= Connection::Client.build '127.0.0.1', 2000
      end

      module ProcessHostIntegration
        def change_connection_scheduler(scheduler)
          connection.scheduler = scheduler
        end
      end
    end
  end
end
