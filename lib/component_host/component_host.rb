module ComponentHost
  def self.start(component_name, &block)
    logger = ::Log.get self

    host = Host.build

    host.instance_exec host, &block

    host.start do
      logger.info "Started component: #{component_name} (ProcessID: #{::Process.pid})"
    end
  end
end
