class ProcessHost
  dependency :logger

  def self.build
    reactor = Connection::Reactor.build
    instance = new reactor
    Telemetry::Logger.configure instance
    instance
  end

  attr_reader :reactor
  attr_writer :exception_notifier

  def initialize(reactor)
    @reactor = reactor
  end

  def exception_notifier
    @exception_notifier or ->*{}
  end

  def register(process)
    reactor.register process
  end

  def run
    reactor.run do |process, error|
      exception_notifier.(process, error)
    end
  end
end
