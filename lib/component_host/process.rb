module ComponentHost
  module Process
    def self.included(cls)
      cls.class_exec do
        include Log::Dependency

        extend Build
        extend ProcessName
        prepend Start

        dependency :send, Actor::Messaging::Send
      end
    end

    Virtual::PureMethod.define self, :start

    module Start
      def start
        logger.trace { "Starting process (ProcessName: #{self.class.process_name})" }

        super

        logger.debug { "Process started (ProcessName: #{self.class.process_name})" }

        AsyncInvocation::Incorrect
      end
    end

    module Build
      def build
        instance = new
        instance.send = Actor::Messaging::Send.new
        instance
      end
    end
  end
end
