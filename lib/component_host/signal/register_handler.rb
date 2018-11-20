module ComponentHost
  module Signal
    class RegisterHandler
      Error = Class.new(RuntimeError)

      include Configure
      include Log::Dependency

      configure :register_signal_handler, constructor: :new

      def self.assure_signal(signal)
        unless ::Signal.list.key?(signal)
          signals = ::Signal.list.keys.sort

          error_message = "Unknown signal #{signal.inspect} (Known signals: #{signals * ', '})"

          logger = Log.get(self)
          logger.error { error_message }

          raise Error, error_message
        end
      end

      def call(signal, &handler)
        self.class.assure_signal(signal)

        logger.trace { "Registering signal handler (Signal: #{signal})" }

        register(signal, &handler)

        logger.debug { "Signal handler registered (Signal: #{signal})" }

        AsyncInvocation::Incorrect
      end

      def register(signal, &handler)
        ::Signal.trap(signal) do |signal_number|
          handler.(signal_number)
        end
      end

      module Substitute
        def self.build
          RegisterHandler.new
        end

        class RegisterHandler < Signal::RegisterHandler
          def handlers
            @handlers ||= {}
          end

          def register(signal, &handler)
            handlers[signal] = handler
          end

          def registered?(signal)
            handlers.key?(signal)
          end

          def receive(signal)
            self.class.assure_signal(signal)

            signal_number = ::Signal.list[signal]

            handler = handlers[signal]

            unless handler.nil?
              handler.(signal_number)
            end
          end
        end
      end
    end
  end
end
