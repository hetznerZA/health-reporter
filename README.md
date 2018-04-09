# HealthReporter

The HealthReporter gem makes the caching of health check requests on services easy.  Simiply register a lambda returning true/false that determines if the service is healthy or not.  The HealthReporter caches the result for future requests using a TTL value.  If the cache is still valid it will not use the lambda to determine service health.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'health_reporter'
```

And then execute:
```bash
bundle
```

Or install it yourself as:
```bash
gem install health_reporter
```

## Configuration


## Testing

Run the rspec test tests using docker compose:

```bash
docker-compose build
docker-compose run --rm health-reporter bundle exec rspec -cfd spec/*
```

## Usage

### Overview

Out of the box you can simply call it as follows with the preconfigured always true self-check lambda:
```ruby
  require 'health_reporter'
  HealthReporter.healthy?
  => true
```

The default values can be overridden as follow:
```ruby
  require 'health_reporter'
  HealthReporter.self_test = lambda{ false }
  HealthReporter.healthy_cache_ttl = 60
  HealthReporter.unhealthy_cache_ttl = 30
  HealthReporter.healthy?
  => false
```

### Configuration on startup

First it is set up somewhere in your service startup (config.ru) where you configure how it determines health:
```ruby
  require 'health_reporter'
  HealthReporter.self_test = lambda{ false }
  HealthReporter.healthy_cache_ttl = 60
  HealthReporter.unhealthy_cache_ttl = 30
```

### Health checking via an endpoint

In the controller/model of the health check you simply call the following and based on the boolean return respond with 200 or 500 for other services to see this service health:
```ruby
  require 'health_reporter'
  HealthReporter.healthy?
  => false
```

### Add service dependencies to check

In a microservices environment the health of a service is also determined by the health of other services it is reaching out to during normal operation.  This gem allows you to register those dependency services to also be checked.  The dependencies are checked along with the service self-check.  The combined health state will be cached.  Therefore whilst the cache is still valid, the dependencies will also not be rechecked.

```ruby
  HealthReporter.register_dependency(url: 'https://hardware-store/status')
```

Or with specific status code and timeout configuration:

```ruby
  HealthReporter.register_dependency(url: 'https://hardware-store/status', code: 200, timeout: 3)
```

## Contributing

Bug reports and feature requests are welcome by email to barney dot de dot villiers at hetzner dot co dot za. This gem is sponsored by Hetzner (Pty) Ltd (http://hetzner.co.za)


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
