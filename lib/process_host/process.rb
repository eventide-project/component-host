module ProcessHost
  module Process
    def self.included(cls)
      cls.class_exec do
        extend ProcessName
      end
    end
  end
end
