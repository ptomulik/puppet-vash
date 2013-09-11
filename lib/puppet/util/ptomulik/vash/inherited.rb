require 'puppet/util/ptomulik'
module Puppet::Util::PTomulik::Vash

module Inherited

  require 'forwardable'
  include ::Enumerable
  extend ::Forwardable

  require 'puppet/util/ptomulik/vash/validator'
  include Validator

  def self.included(base)
    base.extend(ClassMethods)
  end
  require 'puppet/util/ptomulik/vash/class_methods'

  ruby_version = 0;
  RUBY_VERSION.split('.').each{|x| ruby_version <<= 8; ruby_version |= x.to_i}

  def []=(key, value)
    begin 
      validate_item(key, value)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    key, value = munge_item(key, value)
    super(key,value)
  end

  # --
  # On 1.8 alias_method doesn't play nicely with 'super'
  # (raises 'no superclass method'), so we don't use it.
  # ++
  def store(key, value)
    begin 
      validate_item(key, value)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    key, value = munge_item(key, value)
    super(key,value)
  end

  def invert
    hash = super
    begin
      self.dup.replace(hash)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
  end

  def replace(other)
    begin
      validate_hash(other)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    other = munge_hash(other)
    super(other)
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
      validate_hash(other)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    other = munge_hash(other)
    super(other, &block)
  end

  def merge(other, &block)
    begin
      self.dup.merge!(other, &block)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
  end

  def replace(other)
    begin
      validate_hash(other)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    other = munge_hash(other)
    super(other)
  end

  # --
  # On 1.8 alias_method doesn't play nicely with 'super' 
  # (raises 'no superclass method'), so we don't use it.
  # ++
  def update(other, &block)
    begin
      validate_hash(other)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    other = munge_hash(other)
    super(other, &block)
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
    p array.inspect
    hash = munge_hash(Hash[*array])
    self.class.superclass.instance_method(:replace).bind(self).call(hash)
    self
  end

  def replace_with_item_array(array)
    begin
      validate_item_array(array)
    rescue InvalidKeyError, InvalidValueError => err
      raise err.class, err.to_s
    end
    p array.inspect
    hash = munge_hash(Hash[array])
    p hash.inspect
    self.class.superclass.instance_method(:replace).bind(self).call(hash)
    self
  end

end
end
