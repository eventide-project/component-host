module ProcessHost
  class Cooperation
    module Connection
      module Scheduler
        class Cooperative < ::Connection::Scheduler
          attr_reader :dispatcher

          def initialize(dispatcher)
            @dispatcher = dispatcher
          end

          def self.build(dispatcher)
            instance = new dispatcher
            instance.configure_dependencies
            instance
          end

          def wait_readable(io)
            fiber = Fiber.current

            dispatcher.wait_readable io do
              fiber.resume
            end

            Fiber.yield
          end

          def wait_writable(io)
            fiber = Fiber.current

            dispatcher.wait_writable io do
              fiber.resume
            end

            Fiber.yield
          end
        end
      end
    end
  end
end
