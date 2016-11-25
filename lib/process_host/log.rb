module ProcessHost
  class Log < Log
    def tag!(tags)
      tags << :process_host
      tags << :verbose
    end
  end
end
