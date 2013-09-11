require 'spec_helper'
require 'unit/puppet/shared_behaviours/hash'

shared_examples "Vash" do
#  subject { described_class }
  it_behaves_like "Hash"
end
