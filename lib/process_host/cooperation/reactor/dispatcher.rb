module ProcessHost
  class Cooperation
    class Reactor
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

        # Cycle reads and writes so that all tasks get a slice
        def cycle_deferrals
          reads.push reads.shift if reads.any?
          writes.push writes.shift if writes.any?
        end

        def next(&block)
          ready_reads, ready_writes = select

          ready_reads.each do |deferral|
            deferral.callback.()
            reads.delete deferral
          end
          ready_writes.each do |deferral|
            deferral.callback.()
            writes.delete deferral
          end

          cycle_deferrals
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

        def select
          read_ios = reads.map &:io
          write_ios = writes.map &:io

          ready_reads, ready_writes, * = IO.select read_ios, write_ios, [], 1

          read_deferrals = Array(ready_reads).map &method(:pending_read)
          write_deferrals = Array(ready_writes).map &method(:pending_write)

          return read_deferrals, write_deferrals
        end

        def wait_readable(io, &callback)
          logger.debug "Deferring read (Fileno: #{io.fileno})"
          deferral = Deferral.new io, callback
          reads << deferral
        end

        def wait_writable(io, &callback)
          logger.debug "Deferring write (Fileno: #{io.fileno})"
          deferral = Deferral.new io, callback
          writes << deferral
        end
      end
    end
  end
end
