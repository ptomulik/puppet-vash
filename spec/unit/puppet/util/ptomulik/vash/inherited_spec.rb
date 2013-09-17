require 'spec_helper'
require 'puppet/util/ptomulik/vash/inherited'
require 'unit/puppet/shared_behaviours/ptomulik/vash/inherited'

class Vash_Inherited < Hash
  include Puppet::Util::PTomulik::Vash::Inherited
  def self.to_s; 'Vash::Inherited'; end
end

describe Vash_Inherited do
  it_behaves_like 'Vash::Inherited', {
    :sample_items   => [ [:a,:A], ['b','B'] ],
    :valid_items    => [ [:a,:A], ['b','B'] ],
    :invalid_items  => [],
    :hash_arguments => [{:a=>:X, :d=>:D}],
    :missing_key    => :c,
    :missing_value  => :C
  }
end
