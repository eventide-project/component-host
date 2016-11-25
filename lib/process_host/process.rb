module ProcessHost
  module Process
    def self.included(cls)
      cls.class_exec do
        include Log::Dependency

        extend Build
        extend ProcessName
        prepend Start

        dependency :write, Actor::Messaging::Write
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
        instance.write = Actor::Messaging::Write.new
        instance
      end
    end
  end
end
