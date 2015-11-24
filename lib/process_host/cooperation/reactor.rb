module ProcessHost
  class Cooperation
    class Reactor
      attr_reader :fibers

      dependency :dispatcher, Dispatcher
      dependency :logger, Telemetry::Logger

      def initialize
        @fibers = {}
      end

      def self.build
        instance = new
        Dispatcher.configure instance
        Telemetry::Logger.configure instance
        instance
      end

      def register(process, name)
        process.change_connection_scheduler scheduler

        fibers[name] = Fiber.new do
          process.start
        end
      end

      def scheduler
        @scheduler ||= Connection::Scheduler::Cooperative.build dispatcher
      end

      def start
        fibers.each_value &:resume

        while fibers.any?
          logger.debug "Started Iteration (Fibers: #{fibers.keys * ', '})"
          dispatcher.next
          fibers.select! { |_, fiber| fiber.alive? }
        end
      end

      Deferral = Struct.new :io, :callback
    end
  end
end
