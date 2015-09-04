require "observer"

class ProcessHost
  autoload :Builder, "process_host/builder"
  autoload :Heartbeat, "process_host/heartbeat"
  autoload :Iteration, "process_host/iteration"
  autoload :Logging, "process_host/logging"
  autoload :ProcessObserver, "process_host/process_observer"
  autoload :ProcessWrapper, "process_host/process_wrapper"
  autoload :StateMachine, "process_host/state_machine"

  include Logging

  def self.build &block
    Builder.call &block
  end

  attr_accessor :exception_notifier
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

    wrapper = ProcessWrapper.new name, process
    wrapper.add_observer observer
    sm = StateMachine.new wrapper

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

  def heartbeat
    @heartbeat ||= Heartbeat.build config
  end

  def observer
    @observer ||= ProcessObserver.build self
  end
end
