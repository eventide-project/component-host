class ProcessHost
  class Builder
    def self.call &block
      instance = new
      block.(instance)
      instance.call
    end

    attr_writer :exception_notifier
    attr_writer :heartbeat_threshold_ms
    attr_writer :logger
    attr_writer :poll_period_ms

    def call
      ProcessHost.new self
    end

    def exception_notifier
      @exception_notifier or NullExceptionNotifier
    end

    def heartbeat_threshold_ms
      @heartbeat_threshold_ms or 12_000
    end

    def logger
      @logger or NullLogger
    end

    def poll_period_ms
      @poll_period_ms or 5_000
    end

    module NullExceptionNotifier
      def self.call *; end
    end

    module NullLogger
      %i(debug info warn error fatal unknown).each do |method_name|
        define_singleton_method method_name do |*| end
      end
    end
  end

end
