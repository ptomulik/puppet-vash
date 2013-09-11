require 'spec_helper'
require 'puppet/util/ptomulik/vash/validator'
require 'unit/puppet/shared_behaviours/vash_validator.rb'

class Vash_Validator_WithNoValidation
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with no validation]'; end
end

describe Vash_Validator_WithNoValidation do
  include_examples "Vash::Validator", {}
end

class Vash_Validator_WithKeyValidationOnly
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with key validation only]'; end
  def valid_key?(k); k.is_a?(Symbol); end
end

describe Vash_Validator_WithKeyValidationOnly do
  include_examples "Vash::Validator", {
    :with_key_validation => true,
    :valid_keys          => [ :one, :two ],
    :invalid_keys        => [ 'one', 2 ],
    :valid_kvs           => [ [:one,true], [:two,false]],
    :invalid_kvs         => [ ['one',nil,'key'], ['two',nil,'key'] ]
  }
end

class Vash_Validator_WithValueValidationOnly
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with value validation only]'; end
  def valid_value?(v); (v==true) or (v==false); end
end

describe Vash_Validator_WithValueValidationOnly do
  include_examples "Vash::Validator", {
    :with_value_validation => true,
    :valid_values          => [ true, false ],
    :invalid_values        => [ 'true', 0 ],
    :valid_kvs             => [ [:one,true], [:two,false]],
    :invalid_kvs           => [ [nil,'true','val'], [nil,'false','val'] ]
  }
end

class Vash_Validator_WithPairValidationOnly
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with pair validation only]'; end
  def valid_pair?(k,v); v == k*k; end
end

describe Vash_Validator_WithPairValidationOnly do
  include_examples "Vash::Validator", {
    :with_pair_validation   => true,
    :valid_kvs              => [ [1,1], [2,4], [3,9] ],
    :invalid_pairs          => [ [2,1], [2,2], [3,7] ]
  }
end

class Vash_Validator_WithKeyValueValidation
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with key and value validation]'; end
  def valid_key?(k); k.is_a?(Symbol); end
  def valid_value?(v); (v==true) or (v==false); end
end

describe Vash_Validator_WithKeyValueValidation do
  include_examples "Vash::Validator", {
    :with_key_validation   => true,
    :with_value_validation => true,
    :valid_keys            => [ :one, :two ],
    :invalid_keys          => [ 'one', 2 ],
    :valid_values          => [ true, false ],
    :invalid_values        => [ 'true', 0 ],
    :valid_kvs             => [ [:one,true], [:two,false]],
    :invalid_kvs           => [ ['one',true,'key'], [:one,'true','val'] ]
  }
end

class Vash_Validator_WithKeyValueAndPairValidation
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with key, value and pair validation]'; end
  def valid_key?(k); k.is_a?(Fixnum); end
  def valid_value?(v); v.is_a?(Fixnum); end
  def valid_pair?(k,v); v == k*k; end
end

describe Vash_Validator_WithKeyValueAndPairValidation do
  include_examples "Vash::Validator", {
    :with_key_validation   => true,
    :with_value_validation => true,
    :with_pair_validation  => true,
    :valid_keys            => [ 1, 2, 4 ],
    :invalid_keys          => [ '1', :two, true ],
    :valid_values          => [ 1, 5, 6],
    :invalid_values        => [ 'x', :x, nil ],
    :valid_kvs             => [ [1,1], [2,4], [3,9]],
    :invalid_kvs           => [ ['one',1,'key'], [2,'4','val'] ],
    :invalid_pairs         => [ [2,1], [2,2], [3,7] ]
  }
end

class Vash_Validator_WithKeyMungingOnly
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with key munging]'; end
  def munge_key(key); key.downcase.intern; end
end

describe Vash_Validator_WithKeyMungingOnly do
  include_examples "Vash::Validator", {
    :with_key_munging => true,
    :key_munging_map  => {'a' => :a, 'B' => :b},
    :munge_items      => [['a',nil], ['b',0]]
  }
end

class Vash_Validator_WithValueMungingOnly
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with value munging]'; end
  def munge_value(key); key.upcase.intern; end
end

describe Vash_Validator_WithValueMungingOnly do
  include_examples "Vash::Validator", {
    :with_value_munging => true,
    :value_munging_map  => {'a' => :A, 'B' => :B},
    :munge_items        => [[nil,'a'], [0,'B']]
  }
end

class Vash_Validator_WithPairMungingOnly
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with pair munging]'; end
  def munge_pair(k,v); (k<=v) ? [k,v] : [v,k]; end
end

describe Vash_Validator_WithPairMungingOnly do
  include_examples "Vash::Validator", {
    :with_pair_munging => true,
    :pair_munging_map  => {['a','b'] => ['a','b'], ['c','b'] => ['b','c']},
    :munge_items       => [['a','b'], ['c','b'], ['d','d']]
  }
end

class Vash_Validator_WithKeyValueMunging
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with key and value munging]'; end
  def munge_key(key); key.downcase.intern; end
  def munge_value(val); val.upcase.intern; end
end

describe Vash_Validator_WithKeyValueMunging do
  include_examples "Vash::Validator", {
    :with_key_munging   => true,
    :with_value_munging => true,
    :key_munging_map    => {'a' => :a, 'B' => :b},
    :value_munging_map  => {'a' => :A, 'B' => :B},
    :munge_items        => [['a','a'], ['b','B']]
  }
end

class Vash_Validator_WithKeyPairMunging
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with key and pair munging]'; end
  def munge_key(k); k.downcase ; end
  def munge_pair(k,v); (k<=v) ? [k,v] : [v,k]; end
end

describe Vash_Validator_WithKeyPairMunging do
  include_examples "Vash::Validator", {
    :with_key_munging  => true,
    :with_pair_munging => true,
    :key_munging_map   => {'a' => 'a', 'B' => 'b'},
    :pair_munging_map  => {['a','b'] => ['a','b'], ['c','b'] => ['b','c']},
    :munge_items       => [['a','b'], ['C','b'], ['d','d']]
  }
end

class Vash_Validator_WithValuePairMunging
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with value and pair munging]'; end
  def munge_value(v); v.upcase; end
  def munge_pair(k,v); (k<=v) ? [k,v] : [v,k]; end
end

describe Vash_Validator_WithValuePairMunging do
  include_examples "Vash::Validator", {
    :with_value_munging => true,
    :with_pair_munging  => true,
    :value_munging_map  => {'a' => 'A', 'B' => 'B'},
    :pair_munging_map   => {['a','b'] => ['a','b'], ['c','b'] => ['b','c']},
    :munge_items        => [['a','b'], ['C','d'], ['e','e']]
  }
end


class Vash_Validator_WithKeyValueAndPairMunging
  include Puppet::Util::PTomulik::Vash::Validator
  def self.to_s; 'Vash::Validator[with key, value and pair munging]'; end
  def munge_key(k); k.to_s.downcase; end
  def munge_value(v); v.to_s.upcase; end
  def munge_pair(k,v); (k<=v) ? [k,v] : [v,k]; end
end

describe Vash_Validator_WithKeyValueAndPairMunging do
  include_examples "Vash::Validator", {
    :with_key_munging   => true,
    :with_value_munging => true,
    :with_pair_munging  => true,
    :key_munging_map    => {'a' => 'a', :B => 'b'},
    :value_munging_map  => {'a' => 'A', :B => 'B'},
    :pair_munging_map   => {['a','b'] => ['a','b'], ['c','b'] => ['b','c']},
    :munge_items        => [['a','b'], ['C','d'], ['e','e']]
  }
end
