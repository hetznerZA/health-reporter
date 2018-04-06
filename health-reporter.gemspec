# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'health_reporter/version'

Gem::Specification.new do |spec|
  spec.name          = "health-reporter"
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

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2.13'
  spec.add_development_dependency 'simplecov', '~> 0'
  spec.add_development_dependency 'simplecov-rcov', '~> 0'
  spec.add_development_dependency 'byebug', '~> 10'
end
