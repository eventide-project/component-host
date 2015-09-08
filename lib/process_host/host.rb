module ProcessHost
  class Host
    include Logging

    attr_writer :exception_notifier
    attr_writer :poll_period
    attr_writer :watchdog

    def run times = Float::INFINITY, &block
      watchdog.start

      runner = Runner.new poll_period
      runner.logger = logger
      runner.instance_exec &block
      logger.info "Starting host"

      runner.(times)
    rescue Process::Crash => crash
      exception_notifier.(crash.client, crash.cause)
      raise crash.cause
    end

    def poll_period
      @poll_period or 1
    end

    def exception_notifier
      @exception_notifier or ->*{}
    end

    def watchdog
      @watchdog or Watchdog::NullWatchdog
    end
  end
end
