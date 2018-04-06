require 'json'

module HealthReporter
  class Reporter
    attr_accessor :self_test
    attr_accessor :unhealthy_cache_ttl
    attr_accessor :healthy_cache_ttl

    attr_reader   :last_check_time

    def initialize
      @self_test           = lambda{ true }
      @unhealthy_cache_ttl = 30
      @healthy_cache_ttl   = 60

      @last_check_time     = nil

      #Private variables
      @healthy   = nil #Initialized as nil so that first call will set it
      @semaphore = Mutex.new
    end

    def healthy?
      @semaphore.synchronize {
        perform_health_check if @health.nil? or cache_ttl_expired
        @healthy
      }
    end

    private

    def perform_health_check
      @healthy = sanitize(@self_test.call)
      @last_check_time = Time.now
    end

    def sanitize(result)
      unless [true, false].include?(result)
        raise "Invalid non-boolean response from registered self-check lambda: #{result.to_s}"
      end
      result
    end

    def cache_ttl_expired
      return true if @last_check_time.nil?
      Time.now > (@last_check_time + ttl)
    end

    def ttl
      return @healthy_cache_ttl if @healthy
      @unhealthy_cache_ttl
    end
  end
end
