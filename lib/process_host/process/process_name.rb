module ProcessHost
  module Process
    module ProcessName
      def self.extended(cls)
        cls.singleton_class.class_exec do
          attr_writer :process_name
        end
      end

      def process_name_macro(name)
        self.process_name = name
      end

      def process_name(name=nil)
        if name.nil?
          @process_name ||= Default.get self
        else
          process_name_macro name
        end
      end

      module Default
        def self.get(mod)
          constant_name = mod.name

          return unknown if constant_name.nil?

          *, constant_name = constant_name.split '::'

          constant_name = Casing::Underscore.(constant_name)

          constant_name.to_sym
        end

        def self.unknown
          :unknown
        end
      end
    end
  end
end
