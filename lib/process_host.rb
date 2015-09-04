class ProcessHost
  autoload :Builder, "process_host/builder"
  autoload :Heartbeat, "process_host/heartbeat"
  autoload :Logging, "process_host/logging"
  autoload :Manager, "process_host/manager"
  autoload :Set, "process_host/set"

  include Logging

  def self.build &block
    Builder.call &block
  end

  attr_writer :exception_notifier
  attr_reader :heartbeat
  attr_reader :poll_period
  attr_reader :managers
  attr_reader :set

  def initialize heartbeat, poll_period
    @heartbeat = heartbeat
    @poll_period = poll_period
    @managers = []
    @set = Set.new
  end

  def add process, name = nil
    name ||= process.class.name
    manager = Manager.new process, name
    managers << manager
    set[name] = wrap process
    logger.debug "Added manager #{manager.inspect}"
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

  class ProcessWrapper
    attr_reader :process
    attr_reader :heartbeat
    attr_reader :exception_notifier

    def initialize process, heartbeat, exception_notifier
      @process = process
      @heartbeat = heartbeat
      @exception_notifier = exception_notifier
    end

    %i(connect prepare_socket receive_socket).each do |method_name|
      define_method method_name do |*args|
        value = nil

        heartbeat.update
        notify_exceptions do
          value = process.public_send method_name, *args
        end

        heartbeat.update
        value
      end
    end

    def respond_to? method_name
      process.respond_to? method_name
    end

    private

    def notify_exceptions
      return yield
    rescue => error
      exception_notifier.(process, error)
      raise error
    end
  end

  module NullExceptionNotifier
    def self.call *; end
  end
end
