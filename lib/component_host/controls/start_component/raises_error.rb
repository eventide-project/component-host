module ComponentHost
  module Controls
    module StartComponent
      module RaisesError
        def self.call
          raise error, "An example error"
        end

        def self.error
          @error ||= Error.example
        end
      end
    end
  end
end
