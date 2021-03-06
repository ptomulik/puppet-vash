require 'puppet/util/ptomulik/vash'
require 'puppet/util/ptomulik/vash/errors'

module Puppet::Util::PTomulik::Vash
module Contained

  include ::Enumerable

  require 'puppet/util/ptomulik/vash/validator'
  include Validator

  # @api private
  def self.included(base)
    base.extend(ClassMethods)
  end
  require 'puppet/util/ptomulik/vash/class_methods'

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
    rescue VashArgumentError => err
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
    result = vash_underlying_hash.delete_if(&block)
    block ? self : result
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
  # @note Returning instance of self.class would have no sense, especially
  # when key/value validation is in use; keys and values may come from
  # mutually incompatible domains, and we can't simply swap them and put
  # them back to an input validating hash. That's why this function must
  # return an instance of standard {Hash}.
  def invert
    hash = vash_underlying_hash.invert
  end

  if ruby_version >= 0x010903
  # @note This method is available on ruby>= 1.9.3 only.
  # Same as {Hash#keep_if}
  def keep_if(&block)
    result = vash_underlying_hash.keep_if(&block)
    block ? self : result
  end
  end

  # Same as {Hash#merge!}
  def merge!(other, &block)
    begin
      other = vash_validate_hash(other)
    rescue VashArgumentError => err
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
    rescue VashArgumentError => err
      raise err.class, err.to_s
    end
  end

  # Same as {Hash#reject}
  # @note On ruby <2.2. the {#reject} returns an instance of Hash subclass (or
  # enumerator) and on >= 2.2 returns a Hash (or enumerator). We follow this
  # behaviour in Vash::Contained. I'm still in doubt, however, because
  # Vash::Contained is used by classes that are not sub-classing Hash. So,
  # not sure it's 100% right decision.
  #
  # Note, that for standard Hash and its subclasses we have
  # select{...}.class == Hash on ruby 1.9+.
  if ruby_version < 0x020200
  def reject(&block)
    # note, using original 'reject' is more difficult here.
    self.dup.delete_if(&block)
  end
  else
  def reject(&block)
    # note, using original 'reject' is more difficult here.
    vash_underlying_hash.reject(&block)
  end
  end

  # Same as {Hash#reject!}
  def reject!(&block)
    return nil if (result = vash_underlying_hash.reject!(&block)).nil?
    block ? self : result
  end

  # Same as {Hash#replace}
  def replace(other)
    begin
      other = vash_validate_hash(other)
    rescue VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash.replace(other)
    self
  end

  # Similar to {Hash#select}
  # @note On ruby  1.8. the {Hash#select} returns an array (or enumerator)
  # and on 1.9.1+ returns hash (or enumerator). We always return hash or
  # an enumerator.
  #
  # Note, that for standard Hash and its subclasses we have
  # select{...}.class == Hash on ruby 1.9+.
  if ruby_version >= 0x010901
    def select(&block)
      vash_underlying_hash.select(&block)
    end
  else
    def select(&block)
      result = vash_underlying_hash.select(&block)
      block ? Hash[result] : result
    end
  end

  if ruby_version >= 0x010903
  # Same as {Hash#select!}
  def select!(&block)
    return nil if (result = vash_underlying_hash.select!(&block)).nil?
    block ? self : result
  end
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
    rescue VashArgumentError => err
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
    rescue VashArgumentError => err
      raise err.class, err.to_s
    end
    vash_underlying_hash.replace(Hash[array])
    self
  end

end
end
