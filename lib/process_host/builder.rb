module ProcessHost
  class Builder
    def self.call block
      instance = new
      block.(instance)
      instance.call
    end

    attr_accessor :exception_notifier
    attr_accessor :watchdog_timeout
    attr_accessor :logger
    attr_accessor :poll_period_ms

    def call
      process_host = Host.new
      process_host.logger = logger
      process_host.exception_notifier = exception_notifier
      process_host.poll_period = poll_period
      if watchdog_timeout
        process_host.watchdog = build_watchdog
      end
      process_host
    end

    def poll_period
      Rational(poll_period_ms, 1000)
    end

    def poll_period_ms
      @poll_period_ms or 5_000
    end

    def build_watchdog
      watchdog = Watchdog.new watchdog_timeout
      watchdog.logger = logger
      watchdog
    end
  end
end
