module ComponentHost
  module Controls
    module ComponentInitiator
      module StopsImmediately
        def self.call
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
