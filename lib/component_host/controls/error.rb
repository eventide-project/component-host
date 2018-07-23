module ComponentHost
  module Controls
    module Error
      def self.example
        Example.new
      end

      Example = Class.new(RuntimeError)
    end
  end
end
