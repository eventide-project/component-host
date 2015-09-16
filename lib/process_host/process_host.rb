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
    integrate process
    reactor.register process
  end

  def run
    reactor.run do |process, error|
      exception_notifier.(process, error)
    end
  end

  def integrate(process)
    mod_name = "#{process.class}::ProcessHostIntegration"

    if Object.const_defined? mod_name
      mod = Object.const_get mod_name
    else
      mod = DefaultIntegration
    end
    process.extend mod
  end

  module DefaultIntegration
    def start(*)
      raise InvalidProcess.new self
    end

    def change_connection_policy(*)
      raise InvalidProcess.new self
    end
  end

  class InvalidProcess < StandardError
    attr_reader :process

    def initialize(process)
      @process = process
    end

    def to_s
      <<-ERROR.chomp
Process #{process.inspect} must implement a #start and a #change_connection_policy method
      ERROR
    end
  end
end
