module ComponentHost
  module Controls
    module Signal
      module Number
        def self.example(signal=nil)
          signal ||= Signal.example

          ::Signal.list.fetch(signal)
        end
      end
    end
  end
end
