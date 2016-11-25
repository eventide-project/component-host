module ProcessHost
  module Process
    module ProcessName
      def process_name
        @process_name ||= ProcessName.get self.name
      end

      def self.get(constant_name)
        *, constant_name = constant_name.split '::'

        constant_name = Casing::Underscore.(constant_name)

        constant_name.to_sym
      end
    end
  end
end
