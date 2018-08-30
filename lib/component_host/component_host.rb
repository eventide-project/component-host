module ComponentHost
  def self.start(name, &block)
    logger = Log.get(self)

    host = Host.build

    host.instance_exec host, &block

    host.start do
      logger.info(tags: [:*, :component, :start, :lifecycle]) { "Started: #{name} (ProcessID: #{::Process.pid})" }
    end
  end
end
