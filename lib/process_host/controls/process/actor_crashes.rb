module ProcessHost
  module Controls
    module Process
      class ActorCrashes
        include ProcessHost::Process

        def start
          Actor.start
        end

        def self.error
          @error ||= Error.example
        end

        class Actor
          include ::Actor

          handle :start do
            raise error
          end

          def error
            ActorCrashes.error
          end
        end
      end
    end
  end
end
