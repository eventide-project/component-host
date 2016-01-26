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

        fibers[name] = Process.new process
      end

      def scheduler
        @scheduler ||= Connection::Scheduler::Cooperative.build dispatcher
      end

      def start(&callback)
        fibers.each_value &:resume

        while fibers.any?
          logger.opt_debug "Started Iteration (Fibers: #{fibers.keys * ', '})"
          dispatcher.next
          fibers.reject! do |name, process|
            next unless process.finished?
            callback.(name, process.error)
            raise process.error if process.error
            true
          end
        end
      end

      Process = Struct.new :process do
        attr_accessor :error

        def fiber
          @fiber ||= Fiber.new do
            begin
              process.start
            rescue => error
              self.error = error
            end
          end
        end

        def finished?
          !fiber.alive?
        end

        def resume
          fiber.resume
        end
      end

      Deferral = Struct.new :io, :callback
    end
  end
end
