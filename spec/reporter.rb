require 'spec_helper'

describe HealthReporter::Reporter do
  subject { HealthReporter::Reporter.new }

  it 'has a version number' do
    expect(HealthReporter::VERSION).not_to be nil
  end

  context 'when configuring' do
    it 'remembers the self-test lambda passed to it' do
      test_lambda = lambda{ 'ab' == 'cd' }
      subject.self_test = test_lambda
      expect(subject.self_test).to be test_lambda
    end

    it 'uses the self-test lambda passed to it' do
      test_var_sender = Random.new.rand(1...10000)
      test_var_receiver = 0
      test_lambda = lambda{
        test_var_receiver = test_var_sender
        return false
      }
      subject.self_test = test_lambda
      expect(subject.self_test).to be test_lambda
      expect(subject.healthy?).to be false
      expect(test_var_sender).to eq test_var_receiver
    end

    it 'remembers the cache ttl when healthy' do
      subject.healthy_cache_ttl = 10
      expect(subject.healthy_cache_ttl).to eq 10
    end

    it 'remembers the cache ttl when not healthy' do
      subject.unhealthy_cache_ttl = 5
      expect(subject.unhealthy_cache_ttl).to eq 5
    end
  end

  context 'when exercising self-test lambda' do
    it 'allows true to be returned by self-test lambda' do
      test_lambda = lambda{ true }
      subject.self_test = test_lambda
      expect(subject.healthy?).to be true
    end

    it 'allows false to be returned by self-test lambda' do
      test_lambda = lambda{ false }
      subject.self_test = test_lambda
      expect(subject.healthy?).to be false
    end

    it 'raises an exception when non-boolean values are returned by self-test lambda' do
      test_lambda = lambda{ "I don't feel well..." }
      subject.self_test = test_lambda
      expect{subject.healthy?}.to raise_error RuntimeError, "Invalid non-boolean response from registered self-check lambda: I don't feel well..."
    end
  end

  context 'when initialized without any parameters' do
    it 'sets the default self-test lambda to { true }' do
      expect(subject.healthy?).to eq true
    end

    it 'sets the default healthy state cache ttl to 60 seconds' do
      expect(subject.healthy_cache_ttl).to eq 60
    end

    it 'sets the default unhealthy state cache ttl to 30 seconds' do
      expect(subject.unhealthy_cache_ttl).to eq 30
    end
  end

  context 'when calling health check for first time (no cached health state)' do
    it 'calls the configured self-test lambda' do

    end
  end

  context 'when current state is healty' do
    context 'when neither healty-cache-ttl nor unhealty-cache-ttl has expired' do
    end

    context 'when healty-cache-ttl has expired' do
    end

    context 'when unhealty-cache-ttl has expired' do
    end
  end

  context 'when current state is unhealty' do
    context 'when neither healty-cache-ttl nor unhealty-cache-ttl has expired' do
    end

    context 'when healty-cache-ttl has expired' do
    end

    context 'when unhealty-cache-ttl has expired' do
    end
  end
end
