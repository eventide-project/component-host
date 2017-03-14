module ComponentHost
  class Log < Log
    def tag!(tags)
      tags << :component_host
      tags << :verbose
    end
  end
end
