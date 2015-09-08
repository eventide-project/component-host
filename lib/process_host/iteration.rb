module ProcessHost
  class Iteration
    include Logging

    attr_reader :poll_period
    attr_reader :processes
    attr_reader :read_sockets
    attr_reader :write_sockets

    def initialize processes, poll_period
      @poll_period = poll_period
      @processes = processes
      @read_sockets = []
      @write_sockets = []
    end

    def call
      logger.debug "Started iteration"
      ensure_processes_are_connected
      setup_sockets_for_select
      noop and return if noop?
      resume_processes_ready_for_io
    end

    def setup_sockets_for_select
      processes.each do |process|
        read_sockets << process.socket if process.pending_read?
        write_sockets << process.socket if process.pending_write?
      end
    end

    def noop?
      read_sockets.empty? and write_sockets.empty?
    end

    def noop
      logger.debug "There are no sockets to select on; sleeping"
      sleep poll_period
      true
    end

    def ensure_processes_are_connected
      processes.each do |process|
        process.ensure_connected
      end
    end

    def resume_processes_ready_for_io
      select_sockets.each do |socket|
        process = processes.detect do |process|
          process.socket == socket
        end
        process.resume
      end
    end

    def select_sockets
      readable, writeable, _ = IO.select read_sockets, write_sockets, [], poll_period
      sockets = Array(readable) + Array(writeable)
    ensure
      logger.debug "Select found #{sockets.size} sockets ready to use"
    end
  end
end
