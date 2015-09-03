class ProcessHost
  attr_reader :heartbeat_threshold
  attr_reader :last_heartbeat
  attr_reader :poll_period
  attr_reader :processes
  attr_writer :exception_notifier

  def initialize logger, poll_period: 5, heartbeat: 10
    @logger = logger
    @poll_period = poll_period
    @processes = []
    @heartbeat_threshold = heartbeat
  end

  def add process_delegate
    process = Process.new process_delegate
    processes << process
    logger.debug "Added process #{process_delegate.inspect}"
  end

  def run iterations = Float::INFINITY
    update_heartbeat
    Signal.trap "USR1", &method(:check_heartbeat)
    logger.info "Starting infinite loop"

    while iterations > 0
      Iteration.(self)
      iterations -= 1
    end
  end

  def check_heartbeat *;
    seconds = now - last_heartbeat
    if seconds > heartbeat_threshold
      raise HeartbeatError.new heartbeat_threshold
    end
  end

  def update_heartbeat
    @last_heartbeat = now
  end

  def now
    Time.now
  end

  def exception_notifier
    @exception_notifier or ->*{}
  end

  class HeartbeatError < StandardError
    attr_reader :threshold

    def initialize threshold
      @threshold = threshold
    end

    def to_s
      "Heartbeat window of #{threshold}s exceeded"
    end
  end

  class Iteration
    def self.call process_host
      instance = build process_host
      instance.call
    end

    def self.build process_host
      processes = process_host.processes
      poll_period = process_host.poll_period
      logger = process_host.logger
      exception_notifier = process_host.exception_notifier
      new processes, poll_period, logger, exception_notifier
    end

    attr_reader :exception_notifier
    attr_reader :logger
    attr_reader :poll_period
    attr_reader :processes

    def initialize processes, poll_period, logger, exception_notifier
      @logger = logger
      @poll_period = poll_period
      @processes = processes
      @exception_notifier = exception_notifier
    end

    def call
      select_group = next_select_group
      sockets_ready = select select_group

      logger.debug do "Iteration: #{select_group.size} waiting processes" end
      logger.debug do "Process states: #{processes.map(&:state) * ", "}" end
      logger.debug do "There are #{sockets_ready} sockets ready" end

      sockets_ready.each do |socket|
        process = select_group.fetch socket.fileno
        logger.debug do "Process is ready to read: #{process.inspect}" end
        capture_errors process do
          process.ready_to_read
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
      processes.each_with_object Hash.new do |process, hsh|
        capture_errors process do
          new_state = process.advance
          next unless new_state == :waiting
          hsh[process.socket.fileno] = process
        end
      end
    end

    def capture_errors process
      yield
    rescue => error
      exception_notifier.(process.delegate, error)
      raise error
    end
  end

  class Process
    attr_reader :delegate
    attr_reader :socket

    def initialize delegate
      @delegate = delegate
      @prepared = false
    end

    def advance
      public_send state
      state
    end

    def state
      if socket.nil?
        :not_connected
      elsif not prepared?
        :not_prepared
      else
        :waiting
      end
    end

    def not_connected
      @socket = delegate.connect
      not_prepared if socket
    end

    def not_prepared
      delegate.prepare_socket socket if delegate.respond_to? :prepare_socket
      @prepared = true
    end

    def ready_to_read
      delegate.receive_socket socket
      @prepared = false
      @socket = nil if socket.closed?
    end

    def prepared?
      if @prepared then true else false end
    end

    def waiting
    end
  end
end
