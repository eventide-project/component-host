module ProcessHost
  class Watchdog
    include Logging

    POLL_INTERVAL = Rational(500, 1000)

    attr_writer :clock
    attr_reader :mutex
    attr_reader :start_time
    attr_reader :timeout

    def initialize timeout
      @timeout = timeout
      @mutex = Mutex.new
    end

    def start
      logger.info "Starting watchdog"
      reset

      Thread.new do
        Thread.current.abort_on_exception = true

        loop do
          sleep POLL_INTERVAL
          delta = capture_delta
          logger.debug "Watchdog woke up; delta=#{delta}"

          if delta > timeout
            logger.error "Watchdog timer detected a #{delta}s gap between resets (timeout is #{timeout})"
            raise TimeoutError.new delta
          end
        end
      end
    end

    def reset
      time = clock.now
      logger.debug "Resetting watchdog: #{time}"
      mutex.synchronize do
        @start_time = time
      end
    end

    def capture_delta
      t0 = mutex.synchronize do
        start_time
      end
      t1 = clock.now
      t1 - t0
    end

    def clock
      @clock or Time
    end

    module NullWatchdog
      extend self

      def start
      end

      def reset
      end
    end

    class TimeoutError < StandardError
      attr_reader :delta

      def initialize delta
        @delta = delta
      end

      def to_s
        "Watchdog was not reset after #{delta} seconds"
      end
    end
  end
end
