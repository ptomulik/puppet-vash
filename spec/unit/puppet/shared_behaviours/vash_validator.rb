require 'spec_helper'
require 'puppet/util/ptomulik/vash/validator'

def scope
  yield
end

def generate_munge_items(vtor, options)
  _org_items = options[:munge_items]
  _mun_items = nil
  if options[:with_key_munging] and options[:with_value_munging]
    if options[:with_pair_munging]
      _mun_items = _org_items.map{|k,v| 
        vtor.munge_pair(vtor.munge_key(k), vtor.munge_value(v))
      }
    else
      _mun_items = _org_items.map{|k,v| 
        [vtor.munge_key(k), vtor.munge_value(v)]
      }
    end
  elsif options[:with_key_munging]
    if options[:with_pair_munging]
      _mun_items = _org_items.map{|k,v| vtor.munge_pair(vtor.munge_key(k), v) }
    else
      _mun_items = _org_items.map{|k,v| [vtor.munge_key(k), v] }
    end
  elsif options[:with_value_munging]
    if options[:with_pair_munging]
      _mun_items = _org_items.map{|k,v| vtor.munge_pair(k, vtor.munge_value(v)) }
    else
      _mun_items = _org_items.map{|k,v| [k, vtor.munge_value(v)] }
    end
  elsif options[:with_pair_munging]
    _mun_items = _org_items.map{|k,v| vtor.munge_pair(k,v) }
  end
  [_org_items, _mun_items]
end


shared_examples "Vash::Validator#validate_scalar" do |options|

  _type = options[:type]
  _vtor = options[:validator]
  _qsym = "valid_#{_type}?".intern
  _esym = "#{_type}_exception".intern
  _vsym = "validate_#{_type}".intern

  let(:vtor) { _vtor }
  let(:vsym) { _vsym }
  let(:qsym) { _qsym }
  let(:esym) { _esym }

  if options[:enabled]
    options[:valid_scalars].each do |_x|
      context "with #{_type}=#{_x.inspect} (valid)" do
        let(:x) { _x }
        it "should not raise errors" do
          expect { vtor.method(vsym).call(x) }.to_not raise_error
        end
        it "should return true" do
          vtor.method(vsym).call(x).should be_true
        end
        it "should invoke #{_qsym}(#{_x.inspect}) once" do
          vtor.expects(qsym).once.with(x).returns(true)
          vtor.method(vsym).call(x)
        end
      end
    end
    options[:invalid_scalars].each do |_x|
      context "with #{_type}=#{_x.inspect} (invalid)" do
        _err, _msg = _vtor.method(_esym).call(nil,_x)
        let(:x)   { _x }
        let(:err) { _err }
        let(:msg) { _msg }
        it "should raise #{_err.to_s.split(/::/).last} with message: #{_msg}" do
          expect { vtor.method(vsym).call(x) }.to raise_error err, msg
        end
        it "should invoke ##{_esym}(nil,#{_x.inspect}) once" do
          vtor.expects(esym).once.with(nil,x).returns([err,msg])
          begin
            vtor.method(vsym).call(x) 
          rescue err, msg
            # eat exception
          end
        end
      end
    end
  else
    it "##{_vsym}(nil) should not raise errors" do
      expect { vtor.method(vsym).call(nil) }.to_not raise_error
    end
    it "##{_vsym}(nil) should return true" do
      vtor.method(vsym).call(nil).should be_true
    end
  end
end

shared_context "Vash::Validator#validate_invalid_pair" do |options|

  _type  = options[:type]
  _vsym  = "validate_#{_type}"

  _vtor  = options[:validator]
  _key   = options[:key]
  _value = options[:value]
  _i     = options[:i]

  if _type == :hash
    _hash    = options[:hash] 
    _ctx_msg = "with hash=#{_hash.inspect} (invalid pair (#{_key.inspect},#{_value.inspect}))"
    _vargs   = [_hash]
  elsif _type == :item_array or _type == :flat_array
    _array   = options[:array]
    _ctx_msg = "with array=#{_array.inspect} (invalid pair at #{_i})"
    _vargs   = [_array]
  else
    _ctx_msg = "with key=#{_key.inspect} and value=#{_value.inspect} (invalid pair)"
    _vargs   = [_key,_value]
  end

  _err, _msg = _vtor.pair_exception(_i,_key,_value)
  context  _ctx_msg do
    let(:vtor)  { _vtor }
    let(:vsym)  { _vsym }
    let(:vargs) { _vargs }
    let(:err)   { _err }
    let(:msg)   { _msg }
    let(:i)     { _i }
    let(:key)   { _key }
    let(:value) { _value }
    it "should raise #{_err.to_s.split(/::/).last} with message: #{_msg}" do
      expect { vtor.method(vsym).call(*vargs) }.to raise_error err, msg
    end
    it "should invoke #pair_exception(#{_i.inspect},#{_key.inspect},#{_value.inspect}) once" do
      vtor.expects(:pair_exception).once.with(i,key,value).returns([err,msg])
      begin
        vtor.method(vsym).call(*vargs) 
      rescue err, msg
        # eat exception
      end
    end
  end
end

shared_context "Vash::Validator#validate_invalid_item" do |options|
  _type  = options[:type]
  _vsym  = "validate_#{_type}"

  _vtor  = options[:validator]
  _key   = options[:key]
  _value = options[:value]
  _who   = options[:who]
  _i     = options[:i] 

  _esym  = (_who == 'key') ? :key_exception : :value_exception

  _who2 = (_who == 'key') ? "key #{_key.inspect}" : "value #{_value.inspect}"
  if _type == :hash
    _hash    = options[:hash]
    _ctx_msg = "with hash=#{_hash.inspect} (invalid #{_who2})"
    _vargs   = [_hash]
    _eargs   = (_who == 'key') ? [nil,_key] : [nil,_value,_key]
  elsif _type == :item_array or _type == :flat_array
    _array   = options[:array]
    _ctx_msg = "with array=#{_array.inspect} (invalid #{_who2} at #{_i})"
    _vargs   = [_array]
    _eargs   = (_who == 'key') ? [_i,_key] : [_i,_value]
  else
    _ctx_msg = "with key=#{_key.inspect} and value=#{_value.inspect} (invalid #{_who2})"
    _vargs   = [_key,_value]
    _eargs   = (_who == 'key') ? [nil,_key] : [nil,_value]
  end
  _err, _msg =  _vtor.method(_esym).call(*_eargs)

  context _ctx_msg do
    let(:vtor)  { _vtor }
    let(:vargs) { _vargs }
    let(:vsym)  { _vsym }
    let(:esym)  { _esym }
    let(:eargs) { _eargs }
    let(:err)   { _err }
    let(:msg)   { _msg }
    let(:i)     { _i }
    let(:key)   { _key }
    let(:value) { _value }
    it "should raise #{_err.to_s.split(/::/).last} with message: #{_msg}" do
      expect { vtor.method(vsym).call(*vargs) }.to raise_error err, msg
    end
    it "should invoke ##{_esym}(#{_eargs.map{|a| a.inspect}.join(',')})" do
      vtor.expects(esym).once.with(*eargs).returns([err,msg])
      begin
        vtor.method(vsym).call(*vargs)
      rescue err, msg
        # eat our exception
      end
    end
  end
end

shared_context "Vash::Validator#validate_valid_item" do |options|

  _type  = options[:type]
  _vsym  = "validate_#{_type}"
  _vtor  = options[:validator]

  if _type == :hash
    _hash    = options[:hash]
    _ctx_msg = "with hash=#{_hash.inspect} (valid)"
    _args    = [_hash]
    _n       = _hash.length
  elsif _type == :item_array or _type == :flat_array
    _array   = options[:array]
    _ctx_msg = "with array=#{_array.inspect} (valid)"
    _args    = [_array]
    _n       = _array.length
  else
    _key     = options[:key]
    _value   = options[:value]
    _ctx_msg = "with key=#{_key.inspect} and value=#{_value.inspect} (valid)"
    _args    = [_key,_value]
    _n       = 1
  end

  context _ctx_msg do
    let(:vtor)  { _vtor }
    let(:vsym)  { _vsym }
    let(:args)  { _args }
    let(:n)     { _n }
    it "should not raise errors" do
      expect { vtor.method(vsym).call(*args) }.to_not raise_error
    end
    it "should return true" do
      vtor.method(vsym).call(*args).should be_true
    end
    if options[:with_key_validation]
      it "should invoke valid_key? exactly #{_n} time#{_n>1?'s':''}" do
        vtor.expects(:valid_key?).at_least(n).at_most(n)
        vtor.method(vsym)
      end
    else
      it "should not invoke valid_key?" do
        vtor.expects(:valid_key?).never
        vtor.method(vsym)
      end
    end
    if options[:with_value_validation]
      it "should invoke valid_value? exactly #{_n} time#{_n>1?'s':''}" do
        vtor.expects(:valid_value?).at_least(n).at_most(n)
        vtor.method(vsym)
      end
    else
      it "should not invoke valid_value?" do
        vtor.expects(:valid_value?).never
        vtor.method(vsym)
      end
    end
    if options[:with_pair_validation]
      it "should invoke valid_pair? exactly #{_n} time#{_n>1?'s':''}" do
        vtor.expects(:valid_pair?).at_least(n).at_most(n)
        vtor.method(vsym)
      end
    else
      it "should not invoke valid_pair?" do
        vtor.expects(:valid_pair?).never
        vtor.method(vsym)
      end
    end
  end
end


shared_examples "Vash::Validator" do |options|

  validator = described_class.new
  subject! { validator }

  it { should respond_to :key_exception }
  it { should respond_to :value_exception }
  it { should respond_to :pair_exception }
  it { should respond_to :validate_key }
  it { should respond_to :validate_value }
  it { should respond_to :validate_pair }
  it { should respond_to :validate_item }
  it { should respond_to :validate_hash }
  it { should respond_to :validate_item_array }
  it { should respond_to :validate_flat_array }
  it { should respond_to :munge_item }
  it { should respond_to :munge_hash }

  if options[:with_key_validation]
    it { should respond_to :valid_key? }
  end
  if options[:with_value_validation]
    it { should respond_to :valid_value? }
  end
  if options[:with_pair_validation]
    it { should respond_to :valid_pair? }
  end

  if options[:with_key_munging]
    it { should respond_to :munge_key }
  end
  if options[:with_value_munging]
    it { should respond_to :munge_value }
  end
  if options[:with_pair_munging]
    it { should respond_to :munge_pair }
  end

  describe "#key_exception" do
    it "err,msg = #key_exception(nil,nil) should not raise errors" do
      expect { err,msg = subject.key_exception(nil,nil) }.to_not raise_error
    end
    it "should return a pair of [ArgumentError, <String>]" do
      err, msg = subject.key_exception(nil,nil)
      (err <= ArgumentError).should be_true
      msg.should be_a ::String
    end
  end

  describe "#value_exception" do
    it "err,msg = #value_exception(nil,nil) should not raise errors" do
      expect { err,msg = subject.value_exception(nil,nil) }.to_not raise_error
    end
    it "err,msg = #value_exception(nil,nil,nil) should not raise errors" do
      expect { err,msg = subject.value_exception(nil,nil,nil) }.to_not raise_error
    end
    it "should return a pair of [ArgumentError, <String>]" do
      err, msg = subject.value_exception(nil,nil)
      (err <= ArgumentError).should be_true
      msg.should be_a ::String
    end
  end

  describe "#pair_exception" do
    it "err,msg = #pair_exception(nil,nil,nil) should not raise errors" do
      expect { err,msg = subject.pair_exception(nil,nil,nil) }.to_not raise_error
    end
    it "should return a pair of [ArgumentError, <String>]" do
      err, msg = subject.pair_exception(nil,nil,nil)
      (err <= ArgumentError).should be_true
      msg.should be_a ::String
    end
  end

  describe "#validate_key(key)" do
    include_examples "Vash::Validator#validate_scalar", {
      :enabled         => options[:with_key_validation],
      :type            => :key,
      :validator       => validator,
      :valid_scalars   => options[:valid_keys],
      :invalid_scalars => options[:invalid_keys]
    }
  end

  describe "#validate_value(value)" do
    include_examples "Vash::Validator#validate_scalar", {
      :enabled         => options[:with_value_validation],
      :type            => :value,
      :validator       => validator,
      :valid_scalars   => options[:valid_values],
      :invalid_scalars => options[:invalid_values]
    }
  end

  describe "#validate_item(key,value)" do
    if options[:with_key_validation] or options[:with_value_validation]
      options[:valid_kvs].each do |_key, _value|
        include_examples "Vash::Validator#validate_valid_item", {
          :type                  => :item,
          :validator             => validator,
          :key                   => _key,
          :value                 => _value,
          :with_key_validation   => options[:with_key_validation],
          :with_value_validation => options[:with_value_validation],
          :with_pair_validation  => options[:with_pair_validation]
        }
      end
      options[:invalid_kvs].each do |_key, _value, _who|
        include_examples "Vash::Validator#validate_invalid_item", {
          :type      => :item,
          :key       => _key,
          :value     => _value,
          :validator => validator,
          :who       => _who
        }
      end
    elsif not options[:with_pair_validation]
      it "should not raise errors" do
        expect { subject.validate_item(nil,nil) }.to_not raise_error
      end
      it "should return true" do
        subject.validate_item(nil,nil).should be_true
      end
    end
  end

  describe "#validate_pair(key,value)" do
    if options[:with_pair_validation]
      options[:invalid_pairs].each do |_key,_value|
        include_examples "Vash::Validator#validate_invalid_pair", {
          :type      => :pair,
          :key       => _key,
          :value     => _value,
          :validator => validator
        }
      end
    else
      it "should not raise errors" do
        expect { subject.validate_pair(nil,nil) }.to_not raise_error
      end
      it "should return true" do
        subject.validate_pair(nil,nil).should be_true
      end
    end
  end

  describe "#validate_hash(hash)" do
    if options[:with_key_validation] or options[:with_value_validation]
      scope do
        include_examples "Vash::Validator#validate_valid_item", {
          :type                  => :hash,
          :validator             => validator,
          :hash                  => Hash[options[:valid_kvs]],
          :with_key_validation   => options[:with_key_validation],
          :with_value_validation => options[:with_value_validation],
          :with_pair_validation  => options[:with_pair_validation]
        }
      end
      options[:invalid_kvs].each do |_key,_value,_who|
        (_hash = Hash[options[:valid_kvs]])[_key] = _value
        include_examples "Vash::Validator#validate_invalid_item", {
          :type      => :hash,
          :key       => _key,
          :value     => _value,
          :validator => validator,
          :hash      => _hash,
          :who       => _who
        }
      end
    elsif not options[:with_pair_validation]
      it "should not raise errors" do
        expect { subject.validate_hash(nil) }.to_not raise_error
      end
      it "should return true" do
        subject.validate_hash(nil).should be_true
      end
    end
    if options[:with_pair_validation]
      options[:invalid_pairs].each do |_key,_value|
        (_hash = Hash[options[:valid_kvs]])[_key] = _value
        include_examples "Vash::Validator#validate_invalid_pair", {
          :type      => :hash,
          :key       => _key,
          :value     => _value,
          :validator => validator,
          :hash      => _hash
        }
      end
    end
  end

  describe "#validate_item_array(array)" do
    if options[:with_key_validation] or options[:with_value_validation]
      scope do
        include_examples "Vash::Validator#validate_valid_item", {
          :type                  => :item_array,
          :validator             => validator,
          :array                 => options[:valid_kvs],
          :with_key_validation   => options[:with_key_validation],
          :with_value_validation => options[:with_value_validation],
          :with_pair_validation  => options[:with_pair_validation]
        }
      end
      options[:invalid_kvs].each do |_key,_value,_who|
        (0..options[:valid_kvs].length-1).each do |_i|
          # replace one item of valid_kvs at a time with an invalid pair and
          # see what is raised by validator
          (_array = options[:valid_kvs].dup)[_i] = [_key, _value]
          include_examples "Vash::Validator#validate_invalid_item", {
            :type      => :item_array,
            :key       => _key,
            :value     => _value,
            :validator => validator,
            :array     => _array,
            :i         => _i,
            :who       => _who
          }
        end
      end
    elsif not options[:with_pair_validation]
      it "should not raise errors" do
        expect { subject.validate_item_array(nil) }.to_not raise_error
      end
      it "should return true" do
        subject.validate_item_array(nil).should be_true
      end
    end
    if options[:with_pair_validation]
      options[:invalid_pairs].each do |_key,_value|
        (0..options[:valid_kvs].length-1).each do |_i|
          # replace one item of valid_kvs at a time with an invalid pair and
          # see what is raised by validator
          (_array = options[:valid_kvs].dup)[_i] = [_key,_value]
          include_examples "Vash::Validator#validate_invalid_pair", {
            :type      => :item_array,
            :key       => _key,
            :value     => _value,
            :validator => validator,
            :array     => _array,
            :i         => _i
          }
        end
      end
    end
  end

  describe "#validate_flat_array(array)" do
    if options[:with_key_validation] or options[:with_value_validation]
      # we have lazy evaluation, so use _array0 name and not re-use it 
      # in the loop after this context block
      scope do
        _array = options[:valid_kvs].flatten
        include_examples "Vash::Validator#validate_valid_item", {
          :type                  => :flat_array,
          :validator             => validator,
          :array                 => options[:valid_kvs].flatten,
          :with_key_validation   => options[:with_key_validation],
          :with_value_validation => options[:with_value_validation],
          :with_pair_validation  => options[:with_pair_validation]
        }
      end
      options[:invalid_kvs].each do |_key,_value,_who|
        (0..options[:valid_kvs].length-1).each do |_i|
          # replace one item of valid_kvs at a time with an invalid pair and
          # see what is raised by validator
          _array = options[:valid_kvs].flatten
          if _who == 'key'
            _i2 = 2 * _i;
            _array[_i2] = _key
          else
            _i2 = 2 * _i + 1
            _array[_i2] = _value
          end
          include_examples "Vash::Validator#validate_invalid_item", {
            :type      => :flat_array,
            :key       => _key,
            :value     => _value,
            :validator => validator,
            :array     => _array,
            :i         => _i2,
            :who       => _who
          }
        end
      end
    elsif not options[:with_pair_validation]
      it "should not raise errors" do
        expect { subject.validate_flat_array(nil) }.to_not raise_error
      end
      it "should return true" do
        subject.validate_flat_array(nil).should be_true
      end
    end
    if options[:with_pair_validation]
      options[:invalid_pairs].each do |_key,_value|
        (0..options[:valid_kvs].length-1).each do |_i|
          # replace one item of valid_kvs at a time with an invalid pair and
          # see what is raised by validator
          _array = options[:valid_kvs].flatten
          _i2 = 2 * _i
          _array[_i2] = _key
          _array[_i2+1] = _value
          include_examples "Vash::Validator#validate_invalid_pair", {
            :type      => :flat_array,
            :key       => _key,
            :value     => _value,
            :validator => validator,
            :array     => _array,
            :i         => _i2
          }
        end
      end
    end
  end

  if options[:with_key_munging]
    describe "#munge_key" do
        options[:key_munging_map].each do |_org, _mun|
          let(:org) { _org }
          let(:mun) { _mun }
          it "should munge key #{_org.inspect} to #{_mun.inspect}" do
            subject.munge_key(org).should ==  mun
          end
        end
    end
  end

  if options[:with_value_munging]
    describe "#munge_value" do
      options[:value_munging_map].each do |_org, _mun|
        let(:org) { _org }
        let(:mun) { _mun }
        it "should munge value #{_org.inspect} to #{_mun.inspect}" do
          subject.munge_value(org).should ==  mun
        end
      end
    end
  end

  if options[:with_pair_munging]
    describe "#munge_pair" do
      options[:pair_munging_map].each do |_org, _mun|
        let(:org) { _org }
        let(:mun) { _mun }
        it "should munge pair #{_org.inspect} to #{_mun.inspect}" do
          subject.munge_pair(*org).should ==  mun
        end
      end
    end
  end


  describe "#munge_item" do
    scope do
      _org_items, _mun_items = generate_munge_items(validator, options)
      if _mun_items
        _org_items.zip(_mun_items).each do |_org, _mun|
          let(:org) { _org }
          let(:mun) { _mun }
          it "should munge item #{_org.inspect} to #{_mun.inspect}" do
            subject.munge_item(*org).should == mun
          end
        end
      end
    end
  end

  describe "#munge_hash" do
    scope do
      _org_items, _mun_items = generate_munge_items(validator, options)
      if _mun_items
        _org_hash = Hash[_org_items]
        _mun_hash = Hash[_mun_items]
        let(:org_hash) { _org_hash }
        let(:mun_hash) { _mun_hash }
        it "should munge hash #{_org_hash.inspect} to #{_mun_hash.inspect}" do
          subject.munge_hash(org_hash).should == mun_hash
        end
      end
    end
  end

end
