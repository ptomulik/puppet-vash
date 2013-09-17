require 'spec_helper'
require 'puppet/util/ptomulik/vash/errors'

module Puppet::SharedBehaviours; module PTomulik; end; end

module Puppet::SharedBehaviours::PTomulik::Vash
module ContainedMod

  require 'unit/puppet/shared_behaviours/ptomulik/vash/validator'
  include ValidatorMod

  # @api private
  def self.included(base)
    base.extend(ClassMethodsMod)
  end
  require 'unit/puppet/shared_behaviours/ptomulik/vash/class_methods'

  # @api private
  def vash_underlying_hash
    @vash_underlying_hash ||= {}
  end
  private :vash_underlying_hash

  # @api private
  def initialize_copy(other)
    super(other)
    @vash_underlying_hash = Hash[other]
    self
  end

  # @api private
  def initialize(*args,&block)
    super()
    @vash_underlying_hash = Hash.new(*args,&block)
  end

  private :initialize_copy

  require 'forwardable'
  extend ::Forwardable
  def_delegators :vash_underlying_hash,
    :==,
    :[],
    :assoc,
    :compare_by_identity?,
    :default,
    :default=,
    :default_proc,
    :default_proc=,
    :delete,
    :empty?,
    :eql?,
    :fetch,
    :flatten,
    :has_key?,
    :has_value?,
    :hash,
    :include?,
    :inspect,
    :key,
    :key?,
    :keys,
    :length,
    :member?,
    :rassoc,
    :shift,
    :size,
    :to_a,
    :to_h,
    :to_hash,
    :to_s,
    :value?,
    :values,
    :values_at

  ruby_version = 0;
  RUBY_VERSION.split('.').each{|x| ruby_version <<= 8; ruby_version |= x.to_i}

  # Same as {Hash#[]=}
  def []=(key, value)
    begin 
      key,value = vash_validate_item([key, value])
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash[key] = value
  end

  alias_method :store, :[]=

  # Same as {Hash#clear}
  def clear
    vash_underlying_hash.clear
    self
  end

  # Same as {Hash#compare_by_identity}
  def compare_by_identity
    vash_underlying_hash.compare_by_identity
    self
  end

  # Same as {Hash#delete_if}
  def delete_if(&block)
    vash_underlying_hash.delete_if(&block)
    self
  end

  def each(&block)
    result = vash_underlying_hash.each(&block)
    block ? self : result
  end
  
  def each_key(&block)
    result = vash_underlying_hash.each_key(&block)
    block ? self : result
  end
  
  def each_pair(&block)
    result = vash_underlying_hash.each_pair(&block)
    block ? self : result
  end
  
  def each_value(&block)
    result = vash_underlying_hash.each_value(&block)
    block ? self : result
  end

  # Same as {Hash#rehash}
  def rehash
    vash_underlying_hash.rehash
    self
  end

  # Same as {Hash#invert}
  # @note Returning instance of self.class whould have no sense, especially
  # when key/value validation is in used, because keys and values may be
  # in different non-compatible domains, and we can't simply swap them and
  # put them back to an input validating hash. That's why this function must
  # return an instance of standard {Hash}.
  def invert
    hash = vash_underlying_hash.invert
  end

  if ruby_version >= 0x010903
  # @note This method is available on ruby>= 1.9.3 only.
  # Same as {Hash#keep_if}
  def keep_if(&block)
    result = vash_underlying_hash.keep_if(&block)
    block ?  self : result
  end
  end

  # Same as {Hash#merge!}
  def merge!(other, &block)
    begin
      other = vash_validate_hash(other)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash.merge!(other, &block)
    self
  end

  alias_method :update, :merge!

  # Same as {Hash#merge}
  def merge(other, &block)
    begin
      self.dup.merge!(other, &block)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
  end

  # Same as {Hash#reject}
  def reject(&block)
    self.dup.delete_if(&block)
  end

  # Same as {Hash#reject!}
  def reject!(&block)
    return nil if vash_underlying_hash.reject!(&block).nil?
    self
  end

  # Same as {Hash#replace}
  def replace(other)
    begin
      other = vash_validate_hash(other)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash.replace(other)
    self
  end

  if ruby_version < 0x010901
  # Similar to {Hash#select}
  # @note There is difference between this select and {Hash#select} on 
  # ruby < 1.9.1. The {Hash#select} returns an array whereas this method
  # returns a new Vash object. The behavior of {Hash#select} changes in 
  # ruby 1.9.1 such that it also returns a hash.
  def select(&block)
    self.dup.delete_if {|k,v| ! block.call(k,v) }
  end
  else
  # Same as {Hash#select}
  def select(&block)
    self.dup.keep_if(&block)
  end
  end

  if ruby_version >= 0x010903
  # Same as {Hash#select!}
  def select!(&block)
    return nil if vash_underlying_hash.select!(&block).nil?
    self
  end
  end

  # Same as {Hash#replace}
  def replace(other)
    begin
      other = vash_validate_hash(other)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash.replace(other)
    self
  end

  #
  # extra methods for ClassMethods
  #

  # Replace Vash content with the one defined in array.
  #
  # Example
  #
  #     vash.replace_with_flat_array([:a, :A, :b, :B])
  #
  # The `vash` contents would be `{:a => :A, :b => :B}`
  def replace_with_flat_array(array)
    begin
      array = vash_validate_flat_array(array)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash.replace(Hash[*array])
    self
  end

  # Replace Vash content with the one defined in array.
  #
  # Example
  #
  #     vash.replace_with_item_array([[:a, :A], [:b, :B]])
  #
  # The `vash` content would be `{:a => :A, :b => :B}`
  def replace_with_item_array(array)
    begin
      array = vash_validate_item_array(array)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash.replace(Hash[array])
    self
  end
end
end

class Puppet::SharedBehaviours::PTomulik::Vash::Contained
  include Puppet::SharedBehaviours::PTomulik::Vash::ContainedMod
end

require 'unit/puppet/shared_behaviours/ptomulik/vash/hash'
shared_examples 'Vash::Contained' do |_params|
  _sample_items = (_params[:valid_items] || []) +
                  (_params[:invalid_items] || []).map{|item,guilty| item}
  _params = {
    :sample_items => _sample_items,
    :hash_initializers => [_params[:valid_items]] || [],
    :model_class  => Puppet::SharedBehaviours::PTomulik::Vash::Contained,
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
