module ProcessHost
  class IOWrapper
    class DeferredAction
      attr_reader :arguments
      attr_reader :fiber
      attr_reader :socket

      def initialize args, socket, fiber = Fiber.current
        @arguments = args
        @fiber = fiber
        @ready = false
        @socket = socket or fail "socket can't be nil"
      end

      def read?
        false
      end

      def write?
        false
      end

      module NoAction
        extend self

        def finished?
          false
        end

        def read?
          false
        end

        def write?
          false
        end
      end

      class Write < DeferredAction
        def perform
          socket.write_nonblock data
        end

        def write?
          true
        end

        def data
          arguments.fetch 0
        end
      end

      class Gets < DeferredAction
        def perform
          socket.gets
        end

        def read?
          true
        end
      end

      class Puts < DeferredAction
        def perform
          socket.puts line
        end

        def write?
          true
        end

        def line
          arguments.fetch 0
        end
      end

      class Read < DeferredAction
        def perform
          socket.read_nonblock bytes
        end

        def read?
          true
        end

        def bytes
          arguments.fetch 0
        end
      end
    end
  end
end
