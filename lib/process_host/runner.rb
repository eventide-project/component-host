module ProcessHost
  class Runner
    include Logging

    attr_reader :poll_period
    attr_reader :processes

    def initialize poll_period
      @poll_period = poll_period
      @processes = []
    end

    def add name, client
      process = Process.new client, name
      process.logger = logger
      process.start
      processes << process
    end

    def call iteration_count
      logger.debug "Started runner with #{processes.size} processes: #{process_names * ", "}"
      processes.each &:resume

      while iteration_count > 0
        next!
        iteration_count -= 1

        if processes.empty?
          logger.warn "Processes all exited; runner is terminating"
          return
        end
      end
    end

    def next!
      iteration = Iteration.new processes, poll_period
      iteration.logger = logger
      iteration.()
    end

    def process_names
      processes.map &:name
    end
  end
end
