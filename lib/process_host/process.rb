module ProcessHost
  module Process
    def self.included(cls)
      cls.class_exec do
        include Log::Dependency

        extend Build
        extend ProcessName
        prepend Start

        dependency :write, Actor::Messaging::Write
      end
    end

    Virtual::PureMethod.define self, :start

    module Build
      def build
        instance = new
        instance.write = Actor::Messaging::Write.new
        instance
      end
    end
  end
end
