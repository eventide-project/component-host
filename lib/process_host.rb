class ProcessHost
  autoload :Builder, "process_host/builder"
  autoload :Heartbeat, "process_host/heartbeat"
  autoload :Manager, "process_host/manager"

  def self.build &block
    Builder.call &block
  end

  attr_writer :exception_notifier
  attr_reader :heartbeat
  attr_writer :logger
  attr_reader :poll_period
  attr_reader :managers

  def initialize heartbeat, poll_period
    @heartbeat = heartbeat
    @poll_period = poll_period
    @managers = []
  end

  def add manager, name = nil
    name ||= manager.class.name
    manager = Manager.new manager, name
    managers << manager
    logger.debug "Added manager #{manager.inspect}"
  end

  def run iterations = Float::INFINITY
    Signal.trap "USR1", &heartbeat.method(:check)
    logger.info "Starting infinite loop"

    while iterations > 0
      next_iteration
      iterations -= 1
    end
  end

  def next_iteration
    select_group = next_select_group
    sockets_ready = select select_group
    logger.debug &method(:print_iteration)

    sockets_ready.each do |socket|
      manager = select_group.fetch socket.fileno
      logger.debug do "Manager is ready to read: #{manager.inspect}" end
      capture_errors manager do
        manager.activate_process
      end
    end
  end

  def select select_group
    sleep poll_period and return [] if select_group.empty?
    sockets = select_group.values.map &:socket
    sockets, _ = IO.select sockets, [], [], poll_period
    Array(sockets)
  end

  def next_select_group
    managers.each_with_object Hash.new do |manager, hsh|
      capture_errors manager do
        next unless manager.prepare_socket
        hsh[manager.socket.fileno] = manager
      end
    end
  end

  def print_iteration
    processes = managers.map do |manager|
      "#{manager.name}: #{manager.connected? ? "connected" : "not connected"}"
    end

    <<-LOG
Starting iteration; processes:
\t#{processes * "\n\t"}
    LOG
  end

  def capture_errors manager
    yield
  rescue => error
    exception_notifier.(manager.process, error)
    raise error
  end

  def heartbeat
    @heartbeat ||= Heartbeat.build config
  end

  def exception_notifier
    @exception_notifier or NullExceptionNotifier
  end

  def logger
    @logger or NullLogger
  end

  module NullLogger
    %i(debug info warn error fatal unknown).each do |method_name|
      define_singleton_method method_name do |*| end
    end
  end

  module NullExceptionNotifier
    def self.call *; end
  end
end
