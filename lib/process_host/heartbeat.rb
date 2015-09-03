class ProcessHost
  class Heartbeat
    def self.build config
      threshold_secs = Rational(config.heartbeat_threshold_ms, 1_000)
      new threshold_secs
    end

    attr_reader :last_heartbeat
    attr_reader :threshold

    def initialize threshold
      @threshold = threshold
      update
    end

    # A signal handler wired up to #check will send a single argument
    def check _ = nil
      seconds = Time.now - last_heartbeat
      raise Error.new threshold if seconds > threshold
    end

    def update
      @last_heartbeat = Time.now
    end

    class Error < StandardError
      attr_reader :heartbeat

      def initialize heartbeat
        @heartbeat = heartbeat
      end

      def to_s
        "Heartbeat window of #{threshold.heartbeat}s exceeded"
      end
    end

  end
end
