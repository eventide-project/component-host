module ProcessHost
  module Controls
    module Process
      def self.example
        Example.new
      end

      class Example
        include ProcessHost::Process

        attr_accessor :started

        def start
          self.started = true
        end

        module Assertions
          def started?
            started ? true : false
          end
        end
      end
    end
  end
end
