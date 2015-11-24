module ProcessHost
  class Cooperation
    class Reactor
      attr_reader :fibers

      class Dispatcher
        attr_reader :reads
        attr_reader :writes

        dependency :logger, Telemetry::Logger

        def initialize
          @reads = []
          @writes = []
        end

        def self.build
          instance = new
          Telemetry::Logger.configure instance
          instance
        end

        def self.configure(receiver)
          instance = build
          receiver.dispatcher = instance
        end

        def next(&block)
          ready_reads, ready_writes, * = IO.select reads.map(&:io), writes.map(&:io), [], 1

          Array(ready_reads).each do |io|
            deferral = pending_read io
            deferral.callback.()
          end

          Array(ready_writes).each do |io|
            deferral = pending_write io
            deferral.callback.()
          end

          # Cycle reads and writes so that all tasks get a slice
          reads.push reads.shift if reads.any?
          writes.push writes.shift if writes.any?
        end

        def pending_read(io)
          reads.detect do |deferral|
            deferral.io == io
          end
        end

        def pending_write(io)
          writes.detect do |deferral|
            deferral.io == io
          end
        end

        def wait_readable(io, &callback)
          readable, * = IO.select [io], [], [], 0
          logger.debug "Deferring read (Fileno: #{io.fileno})"
          deferral = Deferral.new io, callback
          reads << deferral unless pending_read io
        end

        def wait_writable(io, &callback)
          logger.debug "Deferring write (Fileno: #{io.fileno})"
          deferral = Deferral.new io, callback
          writes << deferral unless pending_write io
        end
      end
      dependency :dispatcher, Dispatcher
      dependency :logger, Telemetry::Logger

      Deferral = Struct.new :io, :callback

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
    end
  end
end
