class ProcessHost
  class ProcessObserver
    def self.build process_host
      new(
        process_host.heartbeat,
        process_host.exception_notifier,
        process_host.logger,
      )
    end

    attr_reader :heartbeat
    attr_reader :exception_notifier
    attr_reader :logger

    def initialize heartbeat, exception_notifier, logger
      @heartbeat = heartbeat
      @exception_notifier = exception_notifier
      @logger = logger
    end

    def update message, *args
      public_send message, *args
    end

    def dispatch process, method_name
      heartbeat.update
      logger.debug "Sending #{method_name.inspect} to process #{process.name.inspect}"
    end

    def error process, error
      logger.fatal <<-ERROR
Process #{process.name.inspect} raised error: #{error}

\t#{error.backtrace * "\n\t"}
      ERROR
      exception_notifier.(process.delegate, error) if exception_notifier
    end
  end
end
