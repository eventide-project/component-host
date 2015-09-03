class ProcessHost
  attr_reader :poll_period
  attr_reader :processes

  def initialize logger, poll_period = 10
    @logger = logger
    @poll_period = poll_period
    @processes = []
  end

  def add process_delegate
    process = Process.new process_delegate
    processes << process
    logger.debug "Added process #{process_delegate.inspect}"
  end

  def run
    logger.info "Starting infinite loop"

    loop do
      Iteration.(self)
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
      new processes, poll_period, logger
    end

    attr_reader :logger
    attr_reader :poll_period
    attr_reader :processes

    def initialize processes, poll_period, logger
      @logger = logger
      @poll_period = poll_period
      @processes = processes
    end

    def call
      select_group = next_select_group
      logger.debug "Iteration: #{select_group.size} waiting processes"
      logger.debug "Process states: #{processes.map(&:state) * ", "}"

      sockets_ready = select select_group
      logger.debug "There are #{sockets_ready} sockets ready"

      sockets_ready.each do |socket|
        process = select_group.fetch socket.fileno
        logger.debug "Process is ready to read: #{process.inspect}"
        process.ready_to_read
      end
    end

    def select select_group
      sockets = select_group.values.map &:socket
      sockets, _ = IO.select sockets, [], [], poll_period
      Array(sockets)
    end

    def next_select_group
      processes.each_with_object Hash.new do |process, hsh|
        new_state = process.advance
        next unless new_state == :waiting
        hsh[process.socket.fileno] = process
      end
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
      not_prepared
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
