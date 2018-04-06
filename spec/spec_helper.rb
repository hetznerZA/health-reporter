require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter "./spec/"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'health_reporter'
