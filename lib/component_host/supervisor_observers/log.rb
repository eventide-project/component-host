module ComponentHost
  module SupervisorObservers
    class Log
      include Actor::Supervisor::Observer
      include ComponentHost::Log::Dependency

      handle Actor::Messages::ActorStarted do |msg|
        logger.debug(tags: [:actor, :lifecycle, :start]) { "Actor started (Address: #{msg.address.id}, Actor: #{msg.actor.digest})" }
      end

      handle Actor::Messages::ActorStopped do |msg|
        logger.debug(tags: [:actor, :lifecycle, :stop]) { "Actor stopped (Address: #{msg.address.id}, Actor: #{msg.actor.digest})" }
      end

      handle Actor::Messages::ActorCrashed do |msg|
        error = msg.error

        logger.error(tags: [:actor, :lifecycle, :stop, :crash]) "Error raised (ErrorClass: #{error.class.name}, Actor: #{msg.actor.digest}, Message: #{error.message.inspect})"
      end
    end
  end
end
