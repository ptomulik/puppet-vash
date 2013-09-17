require 'spec_helper'
require 'puppet/util/ptomulik/vash/contained'
require 'unit/puppet/shared_behaviours/ptomulik/vash/contained'

class Vash_Contained
  include Puppet::Util::PTomulik::Vash::Contained
  def self.to_s; 'Vash::Contained'; end
end

describe Vash_Contained do
  it_behaves_like 'Vash::Contained', {
    :sample_items   => [ [:a,:A], ['b','B'] ],
    :valid_items    => [ [:a,:A], ['b','B'] ],
    :invalid_items  => [],
    :hash_arguments => [{:a=>:X, :d=>:D}],
    :missing_key    => :c,
    :missing_value  => :C
  }
end
