require 'puppet/util/ptomulik'
module Puppet::Util::PTomulik::Vash

module Contained

  require 'forwardable'
  include ::Enumerable
  extend ::Forwardable

  require 'puppet/util/ptomulik/vash/validator'
  include Validator

  def self.included(base)
    base.extend(ClassMethods)
  end
  require 'puppet/util/ptomulik/vash/class_methods'

  def vhash_underlying_hash
    @vhash_underlying_hash ||= {}
  end

  def initialize_copy(other)
    super(other)
    @vhash_underlying_hash = Hash[other]
    self
  end

  def initialize(*args,&block)
    super()
    @vhash_underlying_hash = Hash.new(*args,&block)
  end

  private :initialize_copy

  def_delegators :vhash_underlying_hash,
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

  def []=(key, value)
    begin 
      validate_item(key, value)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    key, value = munge_item(key, value)
    vhash_underlying_hash[key] = value
  end

  alias_method :store, :[]=

  def clear
    vhash_underlying_hash.clear
    self
  end

  def compare_by_identity
    vhash_underlying_hash.compare_by_identity
    self
  end

  def delete_if(&block)
    vhash_underlying_hash.delete_if(&block)
    self
  end

  def each(&block)
    vhash_underlying_hash.each(&block)
    self
  end

  def each_key(&block)
    vhash_underlying_hash.each_key(&block)
    self
  end

  def each_pair(&block)
    vhash_underlying_hash.each_pair(&block)
    self
  end

  def each_value(&block)
    vhash_underlying_hash.each_value(&block)
    self
  end

  def rehash
    vhash_underlying_hash.rehash
    self
  end

  def invert
    hash = vhash_underlying_hash.invert
    begin
      self.dup.replace(hash)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
  end

  if ruby_version >= 0x010903
  def keep_if(&block)
    vhash_underlying_hash.keep_if(&block)
    self
  end
  end

  def merge!(other, &block)
    begin
      validate_hash(other)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    other = munge_hash(other)
    vhash_underlying_hash.merge!(other, &block)
    self
  end

  alias_method :update, :merge!

  def merge(other, &block)
    begin
      self.dup.merge!(other, &block)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
  end

  def reject(&block)
    self.dup.delete_if(&block)
  end

  def reject!(&block)
    return nil if vhash_underlying_hash.reject!(&block).nil?
    self
  end

  def replace(other)
    begin
      validate_hash(other)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    other = munge_hash(other)
    vhash_underlying_hash.replace(other)
    self
  end

  if ruby_version < 0x010903
  # we don't have keep_if on ruby < 1.9.3
  def select(&block)
    self.dup.delete_if {|k,v| ! block.call(k,v) }
  end
  else
  def select(&block)
    self.dup.keep_if(&block)
  end
  end

  if ruby_version >= 0x010903
  def select!(&block)
    return nil if vhash_underlying_hash.select!(&block).nil?
    self
  end
  end

  def replace(other)
    begin
      validate_hash(other)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    other = munge_hash(other)
    vhash_underlying_hash.replace(other)
    self
  end

  #
  # extra methods for ClassMethods
  #
  def replace_with_flat_array(array)
    begin
      validate_flat_array(array)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    hash = munge_hash(Hash[*array])
    vhash_underlying_hash.replace(hash)
    self
  end

  def replace_with_item_array(array)
    begin
      validate_item_array(array)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    hash = munge_hash(Hash[array])
    vhash_underlying_hash.replace(hash)
    self
  end

end
end
