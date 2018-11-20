module ComponentHost
  module Controls
    module Signal
      def self.example
        Interrupt.example
      end

      def self.alternate
        Continue.example
      end

      module Interrupt
        def self.example
          'INT'
        end
      end

      module Continue
        def self.example
          'CONT'
        end
      end

      module Terminate
        def self.example
          'TERM'
        end
      end

      module Stop
        def self.example
          'TSTP'
        end
      end

      module Unknown
        def self.example
          'UNKNOWN'
        end
      end
    end
  end
end
