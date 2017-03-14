module ComponentHost
  module Controls
    module Process
      def self.example
        Example.new
      end

      module Name
        def self.example
          :example_process
        end
      end

      class Example
        include ComponentHost::Process

        process_name Name.example

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
