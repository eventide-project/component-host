module ProcessHost
  module Process
    module Start
      def start
        logger.trace { "Starting process (ProcessName: #{self.class.name})" }

        super

        logger.debug { "Process started (ProcessName: #{self.class.name})" }

        AsyncInvocation::Incorrect
      end
    end
  end
end
