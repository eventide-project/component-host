module ProcessHost
  module Controls
    module Process
      class RunsContinuously
        include ProcessHost::Process

        def start
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
            logger.info "Heartbeat (Counter: #{counter})"

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
