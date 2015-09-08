module ProcessHost
  module Logging
    attr_writer :logger

    def logger
      @logger or NullLogger
    end

    module NullLogger
      %i(debug info warn error fatal unknown).each do |method_name|
        define_singleton_method method_name do |*| end
      end
    end
  end
end
