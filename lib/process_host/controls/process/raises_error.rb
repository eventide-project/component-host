module ProcessHost
  module Controls
    module Process
      class RaisesError
        include ProcessHost::Process

        def start
          raise error
        end

        def error
          self.class.error
        end

        def self.error
          @error ||= Error.example
        end
      end
    end
  end
end
