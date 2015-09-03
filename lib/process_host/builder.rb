class ProcessHost
  class Builder
    def self.call &block
      instance = new
      block.(instance)
      instance.call
    end

    attr_accessor :exception_notifier
    attr_accessor :heartbeat_threshold_ms
    attr_accessor :logger
    attr_accessor :poll_period_ms

    def call
      heartbeat = Heartbeat.new heartbeat_threshold
      process_host = ProcessHost.new heartbeat, poll_period
      process_host.logger = logger
      process_host.exception_notifier = exception_notifier
      process_host
    end

    def heartbeat_threshold
      Rational(heartbeat_threshold_ms, 1_000)
    end

    def heartbeat_threshold_ms
      @heartbeat_threshold_ms or 12_000
    end

    def poll_period
      Rational(poll_period_ms, 1000)
    end

    def poll_period_ms
      @poll_period_ms or 5_000
    end
  end
end
