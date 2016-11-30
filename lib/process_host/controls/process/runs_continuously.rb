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

          handle :start do
            :print_heartbeat
          end

          handle :print_heartbeat do
            logger.info "Heartbeat"

            :delay
          end

          handle :delay do
            sleep 1

            :print_heartbeat
          end
        end
      end
    end
  end
end
