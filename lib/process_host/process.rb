module ProcessHost
  class Process
    include Logging

    attr_reader :client
    attr_reader :fiber
    attr_reader :name

    def initialize client, name = nil
      @client = client
      @name = name || client.class.name
    end

    def start
      @fiber = Fiber.new do
        next! while true
      end
    end

    def ensure_connected
      fiber.resume unless connected?
    end

    def next!
      connect! unless connected?

      if connected?
        client.next! io_wrapper
      else
        Fiber.yield
      end

    rescue => error
      crash =  Crash.new client, error
      raise crash
    end

    def resume
      return_value = io_wrapper.complete_pending_action
      logger.debug "Process #{name.inspect} finished action; returned #{return_value.inspect}"
      fiber.resume return_value
    end

    def io_wrapper
      @io_wrapper ||= IOWrapper.new client
    end

    def connect!
      client.connect io_wrapper
    rescue Errno::ECONNREFUSED
    end

    def connected?
      if io_wrapper.socket then true else false end
    end

    def pending_read?
      io_wrapper.pending_read?
    end

    def pending_write?
      io_wrapper.pending_write?
    end

    def socket
      io_wrapper.socket
    end

    class Crash < StandardError
      attr_reader :cause
      attr_reader :client

      def initialize client, original_error
        @client = client
        @cause = original_error
      end

      def to_s
        cause.to_s
      end

      def backtrace
        cause.backtrace
      end
    end
  end
end
