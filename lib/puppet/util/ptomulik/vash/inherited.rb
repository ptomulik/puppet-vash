require 'puppet/util/ptomulik/vash'
require 'puppet/util/ptomulik/vash/errors'

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
      key, value = vash_validate_item([key, value])
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
    # simply using 'super' cause test failures on 1.8 ... (bug?)
    self.class.superclass.instance_method(:[]=).bind(self).call(key,value)
  end

  def store(key, value)
    begin 
      key, value = vash_validate_item([key, value])
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
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
    self.class.superclass.instance_method(:replace).bind(self).call(other)
  end

  def update(other, &block)
    begin
      other = vash_validate_hash(other)
    rescue Puppet::Util::PTomulik::Vash::VashArgumentError => err
      raise err.class, err.to_s
    end
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
    self.class.superclass.instance_method(:replace).bind(self).call(hash)
    self
  end

end
end
