require 'puppet/util/ptomulik'

module Puppet::Util::PTomulik::Vash

  class InvalidKeyError < ::ArgumentError; end
  class InvalidValueError < ::ArgumentError; end
  class InvalidPairError < ::ArgumentError; end
  class OddArgNoError < ::ArgumentError; end

  module Validator

    def key_exception(i, key)
      msg  = "invalid key #{key.inspect}"
      msg += " at index #{i}" unless i.nil?
      [InvalidKeyError, msg]
    end

    def value_exception(i, value, *args)
      msg  = "invalid value #{value.inspect}"
      msg += " at index #{i}" unless i.nil?
      msg += " at key #{args[0].inspect}" unless args.empty?
      [InvalidValueError, msg]
    end

    def pair_exception(i, key, value)
      msg  = "invalid (key,value) pair (#{key.inspect},#{value.inspect})"
      msg += " at index #{i}" unless i.nil?
      [InvalidPairError, msg]
    end

    def validate_key(key)
      if respond_to?(:valid_key?)
        raise *(key_exception(nil,key)) unless valid_key?(key)
      end
      true
    end

    def validate_value(value)
      if respond_to?(:valid_value?)
        raise *(value_exception(nil,value)) unless valid_value?(value)
      end
      true
    end

    def validate_pair(key, value)
      if respond_to?(:valid_pair?)
        raise *(pair_exception(nil,key,value)) unless valid_pair?(key,value)
      end
      true
    end

    def validate_item(key, value)
      validate_key(key)
      validate_value(value)
      validate_pair(key,value)
    end

    def validate_hash(hash)
      if respond_to?(:valid_key?) and respond_to?(:valid_value?)
        hash.each_pair do |key, value| 
          raise *(key_exception(nil,key)) unless valid_key?(key)
          raise *(value_exception(nil,value,key)) unless valid_value?(value)
        end
      elsif respond_to?(:valid_key?) 
        hash.each_key do |key| 
          raise *(key_exception(nil,key)) unless valid_key?(key)
        end
      elsif respond_to?(:valid_value?)
        hash.each_pair do |key, value|
          raise *(value_exception(nil,value,key)) unless valid_value?(value)
        end
      end
      if respond_to?(:valid_pair?)
        hash.each_pair do |key, value| 
          raise *(pair_exception(nil,key,value)) unless valid_pair?(key,value)
        end
      end
      true
    end

    def validate_flat_array(array)
      def each_even(a)
        i = 0; l = a.length-1; while i<l do; yield [i,a[i]]; i+=2; end
      end
      def each_odd(a)
        i = 1; l = a.length; while i<l do; yield [i,a[i]]; i+=2; end
      end
      def each_even_odd(a)
        i = 0; l = a.length-1; while i<l do; yield [i,a[i],a[i+1]]; i+=2; end
      end
      if (respond_to?(:valid_key?) or respond_to?(:valid_value?) or
          respond_to?(:valid_pair?)) and (array.length % 2) != 0
        raise OddArgNoError, "odd number of arguments for Vash"
      end
      if respond_to?(:valid_key?) and respond_to?(:valid_value?)
        each_even_odd(array) do |i,key,value|
          raise *(key_exception(i,key)) unless valid_key?(key)
          raise *(value_exception(i+1,value)) unless valid_value?(value)
        end
      elsif respond_to?(:valid_key?)
        each_even(array) do |i,key|
          raise *(key_exception(i,key)) unless valid_key?(key)
        end
      elsif respond_to?(:valid_value?)
        each_odd(array) do |i,value|
          raise *(value_exception(i,value)) unless valid_value?(value)
        end
      end
      if respond_to?(:valid_pair?)
        each_even_odd(array) do |i,key,value|
          raise *(pair_exception(i,key,value)) unless valid_pair?(key,value)
        end
      end
      true
    end

    def validate_item_array(array) 
      def each_index_pair(a)
        i = 0; l = a.length; while i<l do; yield [i,a[i][0],a[i][1]]; i+=1; end
      end
      if respond_to?(:valid_key?) and respond_to?(:valid_value?)
        each_index_pair(array) do |i,key,value|
          raise *(key_exception(i,key)) unless valid_key?(key)
          raise *(value_exception(i,value)) unless valid_value?(value)
        end
      elsif respond_to? :valid_key?
        each_index_pair(array) do |i,key,value|
          raise *(key_exception(i,key)) unless valid_key?(key)
        end
      elsif respond_to?(:valid_value?)
        each_index_pair(array) do |i,key,value|
          raise *(value_exception(i,value)) unless valid_value?(value)
        end
      end
      if respond_to?(:valid_pair?)
        each_index_pair(array) do |i,key,value|
          raise *(pair_exception(i,key,value)) unless valid_pair?(key,value)
        end
      end
      true
    end

    def munge_hash(hash)
      if respond_to? :munge_key and respond_to? :munge_value
        if respond_to? :munge_pair
          Hash[hash.map{|k,v| munge_pair(munge_key(k), munge_value(v))}]
        else
          Hash[hash.map{|k,v| [munge_key(k), munge_value(v)]}]
        end
      elsif respond_to? :munge_key
        if respond_to? :munge_pair
          Hash[hash.map{|k,v| munge_pair(munge_key(k), v)}]
        else
          Hash[hash.map{|k,v| [munge_key(k), v]}]
        end
      elsif respond_to? :munge_value
        if respond_to? :munge_pair
          Hash[hash.map{|k,v| munge_pair(k, munge_value(v))}]
        else
          Hash[hash.map{|k,v| [k, munge_value(v)]}]
        end
      elsif respond_to? :munge_pair
        Hash[hash.map{|k,v| munge_pair(k,v)}]
      else
        hash
      end
    end

    def munge_item(key, value)
      key = respond_to?(:munge_key) ? munge_key(key) : key
      value = respond_to?(:munge_value) ? munge_value(value) : value
      key, value = munge_pair(key,value) if respond_to?(:munge_pair)
      [key, value]
    end
  end
end
