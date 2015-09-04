class ProcessHost
  autoload :Builder, "process_host/builder"
  autoload :Heartbeat, "process_host/heartbeat"
  autoload :Iteration, "process_host/iteration"
  autoload :Logging, "process_host/logging"
  autoload :ProcessWrapper, "process_host/process_wrapper"
  autoload :StateMachine, "process_host/state_machine"

  include Logging

  def self.build &block
    Builder.call &block
  end

  attr_writer :exception_notifier
  attr_reader :heartbeat
  attr_reader :poll_period
  attr_reader :processes

  def initialize heartbeat, poll_period
    @heartbeat = heartbeat
    @poll_period = poll_period
    @processes = []
  end

  def add process, name = nil
    name ||= process.class.name
    wrapped_process = wrap process
    sm = StateMachine.new wrapped_process
    processes << sm
    logger.debug "Added process #{process.inspect}"
  end

  def run iterations = Float::INFINITY
    Signal.trap "USR1", &heartbeat.method(:check)
    logger.info "Starting infinite loop"

    while iterations > 0
      heartbeat.update
      iterate
      iterations -= 1
    end
  end

  def iterate
    Iteration.(processes, poll_period)
  end

  def wrap process
    ProcessWrapper.new process, heartbeat, exception_notifier
  end

  def heartbeat
    @heartbeat ||= Heartbeat.build config
  end

  def exception_notifier
    @exception_notifier or NullExceptionNotifier
  end

  module NullExceptionNotifier
    def self.call *; end
  end
end
