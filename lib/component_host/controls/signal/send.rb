module ComponentHost
  module Controls
    module Signal
      module Send
        def self.call(signal=nil)
          signal ||= Signal.example

          pid = ::Process.pid

          begin
            ::Process.kill(signal, pid)
          rescue ::Interrupt
          end
        end
      end
    end
  end
end
