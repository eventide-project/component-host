module ComponentHost
  module Controls
    module StartComponent
      def self.example
        Example.new
      end

      class Example
        attr_accessor :executed

        def call
          self.executed = true
        end

        module Assertions
          def executed?
            executed ? true : false
          end
        end
      end
    end
  end
end
