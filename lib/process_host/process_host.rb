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
    validate process

    reactor.register process
  end

  def run
    reactor.run do |process, error|
      exception_notifier.(process, error)
    end
  end

  def validate(process)
    mod_name = "#{process.class}::Process"

    if Object.const_defined? mod_name
      mod = Object.const_get mod_name
      process.extend mod
    end

    unless process.respond_to? :run
      raise InvalidProcess.new process
    end
  end

  class InvalidProcess < StandardError
    attr_reader :process

    def initialize(process)
      @process = process
    end

    def to_s
      <<-ERROR.chomp
Process #{process} has no run method, nor does it have an embedded Process module that can be extended onto instances and implement run for those instances
      ERROR
    end
  end
end
