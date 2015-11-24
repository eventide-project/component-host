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

    def register(process, name=nil)
      name ||= 'unknown'
      ProcessHost.integrate process
      reactor.register process, name
    end

    def start
      reactor.start do |process, error|
        exception_notifier.(process, error) if exception_notifier
      end
    end
  end
end
