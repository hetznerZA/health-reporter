require 'singleton'
require 'uri'
require 'faraday'

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
  @@dependencies        = {}
  @@last_check_time     = nil
  @@healthy             = nil #Initialized as nil so that first call will set it
  @@semaphore           = Mutex.new

  def self.clear_cache
    @@last_check_time     = nil
    @@healthy             = nil
  end

  def self.clear_dependencies
    @@dependencies = {}
  end

  def self.register_dependencies(provided_dependencies = [])
    provided_dependencies.map{ |dependency|
      symbolized_dependency = Hash[dependency.map{|(k,v)| [k.to_sym,v]}]
      raise 'url not defined for dependency' unless symbolized_dependency[:url]
      add_defaults(symbolized_dependency)
      dependencies[symbolized_dependency[:url]] = symbolized_dependency
      dependencies[symbolized_dependency[:url]].delete(:url)
    }
  end

  def self.dependencies
    @@dependencies
  end

  def self.register_dependency(url:, code: 200, timeout: 2)
    $stderr.puts "The HealthReporter method register_dependency is depreciated. Use fully featured register_dependencies method instead"
    raise "Configured URL #{url} is invalid" unless url =~ URI::regexp
    dependencies[url] = { :code => code, :timeout => timeout }
  end

  def self.healthy?
    @@semaphore.synchronize {
      perform_health_check if @@healthy.nil? or cache_ttl_expired
      @@healthy
    }
  end

  private

  def self.add_defaults(dependency)
    dependency[:code] |= 200
    dependency[:timeout] |= 2
  end

  def self.perform_health_check
    @@last_check_time = Time.now
    @@healthy = sanitize(@@self_test.call)
    check_dependencies if @@healthy
  rescue Exception => exception
    @@healthy = false
    raise
  end

  def self.check_dependencies
    @@dependencies.each { |url, configuration|
      check_dependency(url: url, configuration: configuration)
    }
    @@healthy = true
  end

  def self.check_dependency(url:, configuration:)
    conn = Faraday.new(:url => url)
    response = conn.get do |request|
      request.options.timeout = configuration[:timeout]
      request.options.open_timeout = configuration[:timeout]
    end

    unless response.status == configuration[:code]
      raise "Response expected to be #{configuration[:code]} but is #{response.status}"
    end
  rescue Exception => exception
    @@healthy = false
    raise "Dependency <#{url}> failed check due to #{exception.class}: #{exception.message}"
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
