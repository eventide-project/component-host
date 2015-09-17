module ProcessHost
  class Cooperation
    attr_writer :exception_notifier
    attr_reader :reactor

    dependency :logger

    def initialize(reactor)
      @reactor = reactor
    end

    def self.build
      reactor = Connection::Reactor.build
      instance = new reactor
      Telemetry::Logger.configure instance
      instance
    end

    def exception_notifier
      @exception_notifier or ->*{}
    end

    def register(process, name = nil)
      ProcessHost.integrate process
      reactor.register process, name
    end

    def start
      reactor.run do |process, error|
        exception_notifier.(process, error)
      end
    end
  end
end
