module ComponentHost
  module Controls
    module StartComponent
      module RunsContinuously
        def self.call
          Actor.start
        end

        class Actor
          include ::Actor
          include ::Log::Dependency

          attr_writer :counter

          handle :start do
            :print_heartbeat
          end

          handle :print_heartbeat do
            logger.info(tag: :heartbeat) "Heartbeat (Counter: #{counter})"

            :next
          end

          handle :next do
            self.counter += 1

            sleep 1

            :print_heartbeat
          end

          def counter
            @counter ||= 0
          end
        end
      end
    end
  end
end
