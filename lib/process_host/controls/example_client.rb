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
          logger.trace "Client is writing request headers"
          logger.data "Request headers:\n#{request}"
          connection.write request.to_s
          logger.debug "Client has written request headers"

          builder = HTTP::Protocol::Response::Builder.build
          logger.trace "Client is reading response headers"
          builder << connection.readline("\r\n") until builder.finished_headers?
          logger.debug "Client has read response headers"

          response = builder.message
          logger.data "Response headers:\n#{response}"
          content_length = response["Content-Length"].to_i

          logger.trace "Client is reading response body"
          data = connection.read content_length
          logger.debug "Client has read response body"
          logger.data "Response body:\n#{data}"

          @count = data.to_i
          logger.info "Count is now #{count}; Connection=#{response["Connection"]}"
          connection.close if response["Connection"] == "close"
        end
      end

      def connection
        @connection ||= Connection.client '127.0.0.1', 2000
      end

      module ProcessHostIntegration
        def change_connection_scheduler(scheduler)
          connection.scheduler = scheduler
        end
      end
    end
  end
end
