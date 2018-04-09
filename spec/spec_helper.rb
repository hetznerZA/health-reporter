require 'simplecov'
require 'simplecov-rcov'
require 'timecop'
require 'webmock/rspec'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter "./spec/"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'health_reporter'


def reset_lambda_runner_spy
  @test_variable_from_sender = Random.new.rand(1...100000000000)
  @test_variable_from_receiver = 0
end

def spy_lambda_was_run?
  @test_variable_from_receiver == @test_variable_from_sender
end

def spy_lambda_returning_false
  lambda{
    @test_variable_from_receiver = @test_variable_from_sender
    return false
  }
end

def spy_lambda_returning_true
  lambda{
    @test_variable_from_receiver = @test_variable_from_sender
    return true
  }
end
