require 'spec_helper'

describe HealthReporter do
  subject { HealthReporter }

  it 'has a version number' do
    expect(HealthReporter::VERSION).not_to be nil
  end

  before(:each) do
    subject.healthy_cache_ttl = 60
    subject.unhealthy_cache_ttl = 30
    subject.self_test = lambda{ true }
    subject.class_variable_set(:@@last_check_time, nil)
    subject.class_variable_set(:@@healthy, nil)
    subject.clear_dependencies
    Timecop.return
    reset_lambda_runner_spy
  end

  describe '#self_test' do
    it 'remembers the self-test lambda passed to it' do
      test_lambda = lambda{ 'ab' == 'cd' }
      subject.self_test = test_lambda
      expect(subject.self_test).to be test_lambda
    end

    it 'uses the self-test lambda passed to it' do
      test_lambda = spy_lambda_returning_false
      subject.self_test = test_lambda
      expect(subject.self_test).to be test_lambda
      expect(subject.healthy?).to be false
      expect(spy_lambda_was_run?).to eq true
    end
  end

  describe '#healthy_cache_ttl' do
    it 'remembers the cache ttl when healthy' do
      subject.healthy_cache_ttl = 10
      expect(subject.healthy_cache_ttl).to eq 10
    end
  end

  describe '#unhealthy_cache_ttl' do
    it 'remembers the cache ttl when not healthy' do
      subject.unhealthy_cache_ttl = 5
      expect(subject.unhealthy_cache_ttl).to eq 5
    end
  end

  describe '#register_dependency' do
    it 'remembers when you add a dependency' do
      subject.register_dependency(url: 'https://hardware-store/status', code: 123, timeout: 1)
      expect(subject.dependencies).to eq({
        'https://hardware-store/status' => { :code => 123, :timeout => 1 }
      })
    end

    it 'validates the urls of the dependency during registration' do
      expect{subject.register_dependency(url: 'no-valid-url')}.to raise_error RuntimeError, "Configured URL no-valid-url is invalid"
    end

    it 'adds dependency without removing the dependencies already registered' do
      subject.register_dependency(url: 'https://hardware-store/status', code: 123, timeout: 1)
      subject.register_dependency(url: 'https://grocery-store/status', code: 123, timeout: 1)
      expect(subject.dependencies).to eq({
        'https://hardware-store/status' => { :code => 123, :timeout => 1 },
        'https://grocery-store/status' => { :code => 123, :timeout => 1 }
      })
    end

    it 'does not duplicate similar dependency urls' do
      subject.register_dependency(url: 'https://hardware-store/status', code: 123, timeout: 1)
      subject.register_dependency(url: 'https://hardware-store/status', code: 123, timeout: 1)
      subject.register_dependency(url: 'https://hardware-store/status', code: 123, timeout: 1)
      subject.register_dependency(url: 'https://hardware-store/status', code: 123, timeout: 1)
      subject.register_dependency(url: 'https://grocery-store/status', code: 123, timeout: 1)
      expect(subject.dependencies).to eq({
        'https://hardware-store/status' => { :code => 123, :timeout => 1 },
        'https://grocery-store/status' => { :code => 123, :timeout => 1 }
      })
    end
  end


  def self.register_dependencies(provided_dependencies = [])
    provided_dependencies.map{ |dependency|
      @@dependencies[url] = dependency.delete(:url)
    }
  end


  describe '#register_dependencies' do
    let(:provided_test_dependencies_with_string_keys) {
      [
        {
          "url" => "https://outgoing-mail-proxy.hetzner.co.za/health",
          "code" => 200,
          "timeout" => 3
        },
        {
          "url" => "https://tms.hetzner.co.za/tms-service/status",
          "code" => 200,
          "timeout" => 3
        },
        {
          "url" => "http://mail-manager-staging/status",
          "code" => 200,
          "timeout" => 3
        },
        {
          "url" => "http://mail-manager-staging/status",
          "code" => 200,
          "timeout" => 3,
          "authorization_token" => "api_token"
        },
        {
          "url" => "http://duplicated/status",
          "code" => 200,
          "timeout" => 3,
          "authorization_token" => "api_token"
        },
        {
          "url" => "http://duplicated/status",
          "code" => 200,
          "timeout" => 3,
          "authorization_token" => "api_token"
        },
        {
          "url" => "https://api.staging.konsoleh.co.za/health",
          "code" => 204,
          "timeout" => 2,
          "username" => "checker",
          "password" => "checking"
        }
      ]
    }
    let(:provided_test_dependencies_with_symbol_keys) {
      [
        {
          url: "https://outgoing-mail-proxy.hetzner.co.za/health",
          code: 200,
          timeout: 3
        },
        {
          url: "https://tms.hetzner.co.za/tms-service/status",
          code: 200,
          timeout: 3
        },
        {
          url: "http://mail-manager-staging/status",
          code: 200,
          timeout: 3
        },
        {
          url: "http://mail-manager-staging/status",
          code: 200,
          timeout: 3,
          authorization_token: "api_token"
        },
        {
          url: "http://duplicated/status",
          code: 200,
          timeout: 3,
          authorization_token: "api_token"
        },
        {
          url: "http://duplicated/status",
          code: 200,
          timeout: 3,
          authorization_token: "api_token"
        },
        {
          url: "https://api.staging.konsoleh.co.za/health",
          code: 204,
          timeout: 2,
          username: "checker",
          password: "checking"
        }
      ]
    }
    let(:expected_dependencies) {
      {
        "https://outgoing-mail-proxy.hetzner.co.za/health" => {
          code: 200,
          timeout: 3
        },
        "https://tms.hetzner.co.za/tms-service/status" => {
          code: 200,
          timeout: 3
        },
        "http://mail-manager-staging/status" => {
          code: 200,
          timeout: 3,
          authorization_token: "api_token"
        },
        "http://duplicated/status" => {
          code: 200,
          timeout: 3,
          authorization_token: "api_token"
        },
        "https://api.staging.konsoleh.co.za/health" => {
          code: 204,
          timeout: 2,
          username: "checker",
          password: "checking"
        }
      }
    }
    it 'remembers when you add the dependencies with string keys' do
      subject.register_dependencies(provided_test_dependencies_with_string_keys)
      expect(subject.dependencies).to eq(expected_dependencies)
    end
    it 'remembers when you add the dependencies with symbol keys' do
      subject.register_dependencies(provided_test_dependencies_with_symbol_keys)
      expect(subject.dependencies).to eq(expected_dependencies)
    end


  end

  describe '#clear_cache' do
    it 'clears the cache when requested' do
      subject.healthy?
      expect(subject.class_variable_get('@@healthy')).to be true
      expect(subject.class_variable_get('@@last_check_time')).to_not be nil
      subject.clear_cache
      expect(subject.class_variable_get('@@healthy')).to be nil
      expect(subject.class_variable_get('@@last_check_time')).to be nil
    end
  end

  describe '#healthy?' do
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
        subject.self_test = spy_lambda_returning_false
        expect(subject.healthy?).to be false
        expect(spy_lambda_was_run?).to eq true
      end
    end
  
    context 'when current state is healty' do
      before(:each) do
        subject.self_test = spy_lambda_returning_true
        subject.healthy? #force the self-test
        reset_lambda_runner_spy #reset the spy so that we can see if it was run or not
      end
  
      context 'when neither healty-cache-ttl nor unhealty-cache-ttl has expired' do
        before(:each) do
          subject.unhealthy_cache_ttl = 10
          subject.healthy_cache_ttl   = 10
          Timecop.freeze(Time.now + 5)
        end
  
        it 'does not call the registered self-test lambda' do
          subject.healthy? #request here and test if it was run in expect below
          expect(spy_lambda_was_run?).to eq false
        end
        it 'returns the current healthy state' do
          expect(subject.healthy?).to be true
        end
      end
  
      context 'when healty-cache-ttl has expired' do
        before do
          subject.unhealthy_cache_ttl = 10
          subject.healthy_cache_ttl   =  3
          Timecop.freeze(Time.now + 5)
        end
  
        it 'calls the registered self-test lambda' do
          subject.healthy? #request here and test if it was run in expect below
          expect(spy_lambda_was_run?).to eq true
        end
        it 'returns the current healthy state' do
          expect(subject.healthy?).to be true
        end
      end
  
      context 'when unhealty-cache-ttl has expired' do
        before(:each) do
          subject.unhealthy_cache_ttl =  3
          subject.healthy_cache_ttl   = 10
          Timecop.freeze(Time.now + 5)
        end
  
        it 'does not call the registered self-test lambda' do
          subject.healthy? #request here and test if it was run in expect below
          expect(spy_lambda_was_run?).to eq false
        end
        it 'returns the current healthy state' do
          expect(subject.healthy?).to be true
        end
      end
    end
  
    context 'when current state is unhealty' do
      before(:each) do
        subject.self_test = spy_lambda_returning_false
        subject.healthy? #force the self-test
        reset_lambda_runner_spy #reset the spy so that we can see if it was run or not
      end
  
      context 'when neither healty-cache-ttl nor unhealty-cache-ttl has expired' do
        before(:each) do
          subject.unhealthy_cache_ttl = 10
          subject.healthy_cache_ttl   = 10
          Timecop.freeze(Time.now + 5)
        end
  
        it 'does not call the registered self-test lambda' do
          subject.healthy? #request here and test if it was run in expect below
          expect(spy_lambda_was_run?).to eq false
        end
        it 'returns the current unhealthy state' do
          expect(subject.healthy?).to be false
        end
      end
  
      context 'when healty-cache-ttl has expired' do
        before(:each) do
          subject.unhealthy_cache_ttl = 10
          subject.healthy_cache_ttl   =  3
          Timecop.freeze(Time.now + 5)
        end
  
        it 'does not call the registered self-test lambda' do
          subject.healthy? #request here and test if it was run in expect below
          expect(spy_lambda_was_run?).to eq false
        end
        it 'returns the current unhealthy state' do
          expect(subject.healthy?).to be false
        end
      end
  
      context 'when unhealty-cache-ttl has expired' do
        before(:each) do
          subject.unhealthy_cache_ttl =  3
          subject.healthy_cache_ttl   = 10
          Timecop.freeze(Time.now + 5)
        end
  
        it 'calls the registered self-test lambda' do
          subject.healthy? #request here and test if it was run in expect below
          expect(spy_lambda_was_run?).to eq true
        end
        it 'returns the current unhealthy state' do
          expect(subject.healthy?).to be false
        end
      end
    end
  
    context 'when checking dependencies' do
      context 'when there are no dependencies registered' do
        it 'only performs the self-test' do
          subject.self_test = spy_lambda_returning_false
          expect(subject.healthy?).to be false
          expect(spy_lambda_was_run?).to eq true
        end
      end
  
      context 'when there are multiple dependencies registered' do
        before(:each) do
          subject.register_dependency(url: 'https://hardware-store/status')
          subject.register_dependency(url: 'https://grocery-store/status')
          subject.self_test = spy_lambda_returning_true
        end
  
        it 'performs the self-test and checks all dependencies' do
          stub_request(:get, "https://hardware-store/status").to_return(:status => 200, :body => "", :headers => {})
          stub_request(:get, "https://grocery-store/status").to_return(:status => 200, :body => "", :headers => {})
          expect(subject.healthy?).to be true
          expect(spy_lambda_was_run?).to eq true
        end
  
        it 'indicates healthy if all of the dependencies are healthy' do
          stub_request(:get, "https://hardware-store/status").to_return(:status => 200, :body => "", :headers => {})
          stub_request(:get, "https://grocery-store/status").to_return(:status => 200, :body => "", :headers => {})
          expect(subject.healthy?).to be true
          expect(spy_lambda_was_run?).to eq true
        end
  
        it 'raises a detailed exception indicating why a dependency was determined to be unhealthy state was uncached' do
          stub_request(:get, "https://hardware-store/status").to_return(:status => 500, :body => "", :headers => {})
          stub_request(:get, "https://grocery-store/status").to_return(:status => 200, :body => "", :headers => {})
          expect{subject.healthy?}.to raise_error RuntimeError, "Dependency <https://hardware-store/status> failed check due to RuntimeError: Response expected to be 200 but is 500"
        end
  
        it 'indicates cached unhealthy state if it is unhealthy because a dependency was unhealthy' do
          stub_request(:get, "https://hardware-store/status").to_return(:status => 500, :body => "", :headers => {})
          stub_request(:get, "https://grocery-store/status").to_return(:status => 200, :body => "", :headers => {})
          expect{subject.healthy?}.to raise_error RuntimeError, "Dependency <https://hardware-store/status> failed check due to RuntimeError: Response expected to be 200 but is 500"
          reset_lambda_runner_spy
          expect(subject.healthy?).to be false
          expect(spy_lambda_was_run?).to eq false
        end
      end
    end
  end
end
