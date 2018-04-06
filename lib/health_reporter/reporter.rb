require 'json'

module HealthReporter
  class Reporter
    def initialize(healthy: true)
      @healthy = healthy
    end



    def healthy
      @healthy
    end
  end
end
