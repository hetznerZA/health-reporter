require 'spec_helper'

describe HealthReporter::Reporter do
  subject { HealthReporter::Reporter.new }

  it 'has a version number' do
    expect(HealthReporter::VERSION).not_to be nil
  end

  before(:each) do
    reset_lamda_runner_spy
  end

  context 'when configuring' do
    it 'remembers the self-test lambda passed to it' do
      test_lambda = lambda{ 'ab' == 'cd' }
      subject.self_test = test_lambda
      expect(subject.self_test).to be test_lambda
    end

    it 'uses the self-test lambda passed to it' do
      test_lambda = spy_lambda
      subject.self_test = test_lambda
      expect(subject.self_test).to be test_lambda
      expect(subject.healthy?).to be false
      expect(spy_lamda_was_run?).to eq true
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
    it 'calls the configured self-test lambda and returns health' do
      subject.self_test = spy_lambda
      expect(subject.healthy?).to be false
      expect(spy_lamda_was_run?).to eq true
    end
  end

  context 'when current state is healty' do
    before(:each) do
      subject.self_test = lambda{ true }
      subject.healty? #force the self-test
    end

    context 'when neither healty-cache-ttl nor unhealty-cache-ttl has expired' do
      it 'does not call the registered self-test lambda'
      it 'returns the current healthy state'
    end

    context 'when healty-cache-ttl has expired' do
      it 'calls the registered self-test lambda'
      it 'returns the current healthy state'
    end

    context 'when unhealty-cache-ttl has expired' do
      it 'does not call the registered self-test lambda'
      it 'returns the current healthy state'
    end
  end

  context 'when current state is unhealty' do
    before(:each) do
      subject.self_test = lambda{ false }
      subject.healty? #force the self-test
    end

    context 'when neither healty-cache-ttl nor unhealty-cache-ttl has expired' do
      it 'does not call the registered self-test lambda'
      it 'returns the current unhealthy state'
    end

    context 'when healty-cache-ttl has expired' do
      it 'does not call the registered self-test lambda'
      it 'returns the current unhealthy state'
    end

    context 'when unhealty-cache-ttl has expired' do
      it 'calls the registered self-test lambda'
      it 'returns the current unhealthy state'
    end
  end
end
