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

    it 'remembers the cache ttl when healthy' do
      subject.healthy_cache_ttl = 10
      expect(subject.healthy_cache_ttl).to eq 10
    end

    it 'remembers the cache ttl when not healthy' do
      subject.unhealthy_cache_ttl = 5
      expect(subject.unhealthy_cache_ttl).to eq 5
    end

  end

  context 'when initialized without any parameters' do
    it 'sets the default self-test lambda to { true }' do
      expect(subject.healthy).to eq true
    end

    it 'sets the default healthy state cache ttl to 60 seconds' do
      expect(subject.healthy_cache_ttl).to eq 60
    end

    it 'sets the default unhealthy state cache ttl to 30 seconds' do
      expect(subject.unhealthy_cache_ttl).to eq 30
    end
  end

end
