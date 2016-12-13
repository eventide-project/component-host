module ProcessHost
  module SupervisorObservers
    class Log
      include Actor::Supervisor::Observer
      include ProcessHost::Log::Dependency

      handle Actor::Messages::ActorStarted do |msg|
        logger.debug "Actor started (Address: #{msg.address.id}, Actor: #{msg.actor.digest})"
      end

      handle Actor::Messages::ActorStopped do |msg|
        logger.debug "Actor stopped (Address: #{msg.address.id}, Actor: #{msg.actor.digest})"
      end

      handle Actor::Messages::ActorCrashed do |msg|
        error = msg.error

        logger.error "Error raised (ErrorClass: #{error.class.name}, Actor: #{msg.actor.digest}, Message: #{error.message.inspect})"
      end
    end
  end
end
