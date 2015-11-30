module ProcessHost
  def self.integrate(process)
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

    def change_connection_scheduler(*)
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
Process #{process.inspect} must implement a #start and a #change_connection_scheduler method
      ERROR
    end
  end
end
