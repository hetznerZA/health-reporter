require 'spec_helper'
require 'yaml'

describe HealthReporter::Reporter do
  subject { HealthReporter::Reporter }

  it 'has a version number' do
    expect(HealthReporter::VERSION).not_to be nil
  end


end
