module ProcessHost
  module Signal
    module Substitute
      def self.build
        Signal.new
      end

      class Signal
        def trap(signal, &handler)
          handlers[signal] = handler
        end

        def simulate_signal(signal)
          handler = handlers[signal]

          return if handler.nil?

          handler.()

          record = Record.new signal
          records << record
          record
        end

        def handlers
          @handlers ||= {}
        end

        def records
          @records ||= []
        end

        Record = Struct.new :signal

        module Assertions
          def trapped?(signal=nil)
            if signal.nil?
              records.any?
            else
              records.any? { |record| record.signal == signal }
            end
          end
        end
      end
    end
  end
end
