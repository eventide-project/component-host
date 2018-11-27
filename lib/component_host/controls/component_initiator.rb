module ComponentHost
  module Controls
    module ComponentInitiator
      def self.example
        Example.new
      end

      class Example
        attr_accessor :executed

        def call
          self.executed = true
        end

        def executed?
          executed ? true : false
        end
      end
    end
  end
end
