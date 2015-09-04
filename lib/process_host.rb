class ProcessHost
  autoload :Builder, "process_host/builder"
  autoload :Heartbeat, "process_host/heartbeat"
  autoload :Logging, "process_host/logging"
  autoload :Set, "process_host/set"
  autoload :ProcessWrapper, "process_host/process_wrapper"

  include Logging

  def self.build &block
    Builder.call &block
  end

  attr_writer :exception_notifier
  attr_reader :heartbeat
  attr_reader :poll_period
  attr_reader :set

  def initialize heartbeat, poll_period
    @heartbeat = heartbeat
    @poll_period = poll_period
    @set = Set.new
  end

  def add process, name = nil
    name ||= process.class.name
    set[name] = wrap process
    logger.debug "Added process #{process.inspect}"
  end

  def run iterations = Float::INFINITY
    Signal.trap "USR1", &heartbeat.method(:check)
    logger.info "Starting infinite loop"

    while iterations > 0
      heartbeat.update
      set.next_process poll_period
      iterations -= 1
    end
  end

  def heartbeat
    @heartbeat ||= Heartbeat.build config
  end

  def exception_notifier
    @exception_notifier or NullExceptionNotifier
  end

  def wrap process
    ProcessWrapper.new process, heartbeat, exception_notifier
  end

  module NullExceptionNotifier
    def self.call *; end
  end
end
