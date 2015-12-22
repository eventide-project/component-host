module ProcessHost
  class Cooperation
    attr_accessor :exception_notifier
    attr_reader :reactor

    dependency :logger, Telemetry::Logger

    def initialize(reactor)
      @reactor = reactor
    end

    def self.build
      reactor = Reactor.build
      instance = new reactor
      Telemetry::Logger.configure instance
      instance
    end

    def register(process, name)
      ProcessHost.integrate process
      reactor.register process, name
    end

    def start(&block)
      reactor.start do |process, error|
        if error
          exception_notifier.(process, error) if exception_notifier
        else
          block.(process) if block
        end
      end
    end

    def start!
      start do |process|
        fail "Process #{process.inspect} exited"
      end
    end
  end
end
