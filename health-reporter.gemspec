# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'health_reporter/version'

Gem::Specification.new do |spec|
  spec.name          = "health_reporter"
  spec.version       = HealthReporter::VERSION
  spec.authors       = ["Barney de Villiers"]
  spec.email         = ["barney.de.villiers@hetzner.co.za"]
  spec.description   = %q{Health reporter}
  spec.summary       = %q{Health reporter with dependency monitoring and caching capabilties}
  spec.homepage      = "https://github.com/hetznerZA/health-reporter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'soar_xt', '~> 0.0.3'
  spec.add_dependency 'jwt', '~> 1.5', '>= 1.5.6'
  spec.add_dependency "rack", '>= 1.6.4', '< 3.0.0'
  spec.add_dependency 'authenticated_client', '~> 0.0.2'
  spec.add_dependency 'http-cookie', '~> 1.0', '>= 1.0.3'

  spec.add_development_dependency 'auth_token_store_provider', "~> 1.0"
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2.13'
  spec.add_development_dependency "capybara", '~> 2.1', '>= 2.1.0'
  spec.add_development_dependency "simplecov", '~> 0'
  spec.add_development_dependency "simplecov-rcov", '~> 0'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'byebug'
end
