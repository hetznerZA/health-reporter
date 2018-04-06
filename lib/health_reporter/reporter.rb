require 'json'

module HealthReporter
  class Reporter
    attr_accessor :self_test
    attr_accessor :unhealthy_cache_ttl
    attr_accessor :healthy_cache_ttl

    def initialize
      @self_test           = lambda{ true }
      @unhealthy_cache_ttl = 30
      @healthy_cache_ttl   = 60
    end

    def healthy
      @self_test.call
    end
  end
end
