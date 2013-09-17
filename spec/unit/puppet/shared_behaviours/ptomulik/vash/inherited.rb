require 'spec_helper'
require 'puppet/util/ptomulik/vash/errors'

module Puppet::SharedBehaviours; module PTomulik; end; end

module Puppet::SharedBehaviours::PTomulik::Vash
module InheritedMod

  require 'unit/puppet/shared_behaviours/ptomulik/vash/validator'
  include ValidatorMod

  def self.included(base)
    base.extend(ClassMethodsMod)
  end
  require 'unit/puppet/shared_behaviours/ptomulik/vash/class_methods'

  ruby_version = 0;
  RUBY_VERSION.split('.').each{|x| ruby_version <<= 8; ruby_version |= x.to_i}

  def []=(key, value)
    begin 
      key, value = vash_validate_item([key, value])
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    self.class.superclass.instance_method(:[]=).bind(self).call(key,value)
  end

  def store(key, value)
    begin 
      key, value = vash_validate_item([key, value])
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    # On 1.8 using 'super' breaks rspec tests :(.
    self.class.superclass.instance_method(:store).bind(self).call(key,value)
  end

  if ruby_version < 0x010901
  # we don't have keep_if on ruby < 1.9.3
  def select(&block)
    self.dup.delete_if {|k,v| ! block.call(k,v) }
  end
  else
  def select(&block)
    self.dup.keep_if(&block)
  end
  end

  def merge!(other, &block)
    begin
      other = vash_validate_hash(other)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    # On 1.8 using 'super' breaks rspec tests :(.
    self.class.superclass.instance_method(:merge!).bind(self).call(other, &block)
  end

  def merge(other, &block)
    begin
      self.dup.merge!(other, &block)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
  end

  def replace(other)
    begin
      other = vash_validate_hash(other)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    # On 1.8 using 'super' breaks rspec tests :(.
    self.class.superclass.instance_method(:replace).bind(self).call(other)
  end

  # --
  # On 1.8 alias_method doesn't play nicely with 'super' 
  # (raises 'no superclass method'), so we don't use it.
  # ++
  def update(other, &block)
    begin
      other = vash_validate_hash(other)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    # On 1.8 using 'super' breaks rspec tests :(.
    self.class.superclass.instance_method(:update).bind(self).call(other, &block)
  end


  #
  # extra methods for ClassMethods
  #
  def replace_with_flat_array(array)
    begin
      array = vash_validate_flat_array(array)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    hash = Hash[*array]
    # On 1.8 using 'super' breaks rspec tests :(.
    self.class.superclass.instance_method(:replace).bind(self).call(hash)
    self
  end

  def replace_with_item_array(array)
    begin
      array = vash_validate_item_array(array)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    hash = Hash[array]
    # On 1.8 using 'super' breaks rspec tests :(.
    self.class.superclass.instance_method(:replace).bind(self).call(hash)
    self
  end

end
end

class Puppet::SharedBehaviours::PTomulik::Vash::Inherited < ::Hash
  include Puppet::SharedBehaviours::PTomulik::Vash::InheritedMod
end

require 'unit/puppet/shared_behaviours/ptomulik/vash/hash'
shared_examples 'Vash::Inherited' do |_params|
  _sample_items = (_params[:valid_items] || []) +
                  (_params[:invalid_items] || []).map{|item,guilty| item}
  _params = {
    :sample_items => _sample_items,
    :hash_initializers => [_params[:valid_items]] || [],
    :model_class  => Puppet::SharedBehaviours::PTomulik::Vash::Inherited,
    # method exceptions
    :class_sqb=> { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError, ArgumentError]},
    :[]=      => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
    :store    => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
    :replace  => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
    :merge    => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
    :merge!   => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
    :update   => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
    :replace_with_flat_array => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
    :replace_with_item_array => { :raises=>[Puppet::Util::PTomulik::Vash::VashArgumentError] },
  }.merge(_params)
  include_examples 'Vash::Validator', _params
  include_examples 'Vash::Hash', _params
end
