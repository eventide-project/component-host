module ComponentHost
  class Log < Log
    def tag!(tags)
      tags << :component_host
    end
  end
end
