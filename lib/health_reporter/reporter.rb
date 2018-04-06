require 'singleton'

class HealthReporter
  include Singleton

  def self.self_test
    @@self_test
  end

  def self.self_test=(self_test)
    @@self_test = self_test
  end

  def self.unhealthy_cache_ttl
    @@unhealthy_cache_ttl
  end

  def self.unhealthy_cache_ttl=(unhealthy_cache_ttl)
    @@unhealthy_cache_ttl = unhealthy_cache_ttl
  end

  def self.healthy_cache_ttl
    @@healthy_cache_ttl
  end

  def self.healthy_cache_ttl=(healthy_cache_ttl)
    @@healthy_cache_ttl = healthy_cache_ttl
  end

  @@self_test = lambda{ true }
  @@unhealthy_cache_ttl = 30
  @@healthy_cache_ttl   = 60
  @@last_check_time     = nil
  @@healthy             = nil #Initialized as nil so that first call will set it
  @@semaphore           = Mutex.new

  # TODO
  # def register_dependency_check(url:, code: 200)
  #   raise "Configured URL #{url} is invalid" unless url =~ URI::regexp
  #
  #   dependencies[]
  # end

  def self.healthy?
    @@semaphore.synchronize {
      perform_health_check if @@healthy.nil? or cache_ttl_expired
      @@healthy
    }
  end

  private

  def self.perform_health_check
    @@healthy = sanitize(@@self_test.call)
    @@last_check_time = Time.now
  end

  def self.sanitize(result)
    unless [true, false].include?(result)
      raise "Invalid non-boolean response from registered self-check lambda: #{result.to_s}"
    end
    result
  end

  def self.cache_ttl_expired
    return true if @@last_check_time.nil?
    Time.now > (@@last_check_time + ttl)
  end

  def self.ttl
    return @@healthy_cache_ttl if @@healthy
    @@unhealthy_cache_ttl
  end
end
