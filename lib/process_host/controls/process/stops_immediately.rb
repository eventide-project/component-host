module ProcessHost
  module Controls
    module Process
      class StopsImmediately
        include ProcessHost::Process

        def start
          Actor.start
        end

        class Actor
          include ::Actor

          handle :start do
            :stop
          end
        end
      end
    end
  end
end
