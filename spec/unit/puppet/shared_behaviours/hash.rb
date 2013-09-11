require 'spec_helper'

shared_examples "Hash" do

  ruby_version = 0;
  RUBY_VERSION.split('.').each{|x| ruby_version <<= 8; ruby_version |= x.to_i}

  let!(:obj)  { Object.new }
  subject!    { described_class.new }

  [ 
    :==, :[], :[]=, :clear, :default, :default=, :default_proc, :delete,
    :delete_if, :each, :each_key, :each_pair, :each_value, :empty?, :eql?,
    :fetch, :has_key?, :has_value?, :hash, :include?, :inspect, :invert,
    :key?, :keys, :length, :member?, :merge, :merge!, :rehash,
    :reject!, :reject, :replace,  :select, :shift, :size, :store, :to_a,
    :to_hash, :to_s, :update, :value?, :values, :values_at 
  ].each do |method|
    it { should respond_to method }
  end

  if ruby_version >= 0x010901
    it { should respond_to :assoc }
    it { should respond_to :compare_by_identity }
    it { should respond_to :compare_by_identity? }
    it { should respond_to :default_proc= }
    it { should respond_to :flatten }
    it { should respond_to :key }
    it { should respond_to :rassoc }
  end

  if ruby_version >= 0x010903
    it { should respond_to :keep_if }
    it { should respond_to :select! }
  end

  if ruby_version >= 0x020000
    it { should respond_to :to_h }
  end

  describe "::[]" do
    it "#{described_class.to_s}[] should not raise errors" do
      expect { described_class[] }.to_not raise_error
    end
    it "#{described_class.to_s}['a','b'] should not raise error" do
      expect { described_class['a','b'] }.to_not raise_error
    end
    it "#{described_class.to_s}['a'] should raise ArgumentError" do
      re = /^odd number of arguments/
      expect { described_class['a'] }.to raise_error ArgumentError, re
    end
    it "#{described_class.to_s}[['a','A']] should not raise errors" do
      expect { described_class[['a','A']] }.to_not raise_error
    end
    it "#{described_class.to_s}[{'a' => 'A'}] should not raise errors" do
      expect { described_class[{'a' => 'A'}] }.to_not raise_error
    end
    it "#{described_class.to_s}['a','A']['a'] == 'A'" do
      described_class['a','A']['a'].should == 'A'
    end
    it "#{described_class.to_s}['a','A'] == #{described_class.to_s}[[ ['a','A'] ]]" do
      described_class['a','A'].should == described_class[[ ['a','A'] ]]
    end
    it "#{described_class.to_s}['a','A'] == #{described_class.to_s}[{'a'=>'A'}]" do
      described_class['a','A'].should == described_class[{'a'=>'A'}]
    end
  end

  describe "::new" do
    it "#{described_class}.new should not raise error" do
      expect { described_class.new }.to_not raise_error
    end
    it "#{described_class}.new('x') should not raise error" do
      expect { described_class.new('x') }.to_not raise_error
    end
    it "#{described_class}.new {|h,k| k*k } should not raise error" do
      expect { described_class.new{|h,k| k*k} }.to_not raise_error
    end
    it "#{described_class}.new.default.equal? nil" do
      described_class.new.default.should equal nil
    end
    it "#{described_class}.new(:a).default.equal? :a" do
      described_class.new(:a).default.should equal :a
    end
    it "#{described_class}.new{|h,k| k*k}[2] == 4" do
      described_class.new{|h,k| k*k}[2].should == 4
    end
  end

  describe "#==" do
    [
      [{}, {}, true],
      [{'a' => 'A'}, {'a' => 'A'}, true],
      [{'a' => 'A'}, {'b' => 'A'}, false],
      [{'a' => 'A'}, {'a' => 'B'}, false]
    ].each do |h1, h2, result|
      context "#{h1.inspect} == #{h2.inspect}" do
        let(:h1) { described_class.new.replace(h1) }
        let(:h2) { described_class.new.replace(h2) }
        let(:result) { result }
        it {(h1 == h2).should(result ? be_true : be_false)}
      end
    end
  end

  describe "#[]" do
    it "{ :a => obj }[:a] should be obj" do
      subject.replace({:a => obj})
      subject[:a].should be obj
    end
    it "{ :a => :A }['a'] should be nil" do
      subject.replace({:a => :A})
      subject['a'].should be_nil
    end
  end

  describe "#[]=" do
    it "#['a'] = obj should return obj" do
      (subject['a'] = obj).should be obj
    end
    it "#['a'] should return obj after #['a']=obj" do
      subject['a'] = obj
      subject['a'].should be obj
    end
  end

  # assoc is only available in ruby > 1.8
  if ruby_version >= 0x010901
    describe "#assoc" do
      it "{'a' => 'A'}.assoc('a') should return ['a','A']" do
        subject.replace({'a' => 'A'})
        subject.assoc('a').should == ['a', 'A']
      end
      it "{'a' => 'A'}.assoc('b') should return nil" do
        subject.replace({'a' => 'A'})
        subject.assoc('b').should be_nil
      end
    end
  end

  describe "#clear" do
    it "should return self" do
      subject.clear.should be subject
    end
  end

  if ruby_version >= 0x010901
    describe "#compare_by_identity" do
      it "should return self" do
        subject.compare_by_identity.should be subject
      end
      it "{'a' => 'A'}['a'] should be nil after #compare_by_identity" do
        subject.replace({'a' => 'A'})
        subject.compare_by_identity
        subject['a'].should be_nil
      end
      it "{:a => obj}[:a] should be obj after #compare_by_identity" do
        subject.replace({:a => obj})
        subject.compare_by_identity
        subject[:a].should be obj
      end
    end
    describe "#compare_by_identity?" do
      it "should be initially false" do
        subject.compare_by_identity?.should be_false
      end
      it "should be true after #compare_by_identity" do
        subject.compare_by_identity
        subject.compare_by_identity?.should be_true
      end
    end
  end

  describe "#default=" do
    it "#default=obj should return obj" do
      (subject.default = :x).should be :x
    end
  end

  describe "#default" do
    it "should be nil initially" do
      subject.default.should be_nil
    end
    it "should return obj after #default=obj" do
      subject.default = obj
      subject.default.should be obj
    end
  end

  if ruby_version >= 0x010901
    describe "#default_proc=" do
      it "#default_proc=p should return p" do
        p = proc {|h,k| h[k] = k*k}
        (subject.default_proc = p).should be p
      end
    end
  end

  describe "#default_proc" do
    it "should be nil initially" do
      subject.default_proc.should be_nil
    end
    if ruby_version >= 0x010901
      # we can use only instance methods, for < 1.9 there is no other way to
      # set default_proc  as via class method (new)
      it "should return p after #default_proc=p" do
        p = proc {|h,k| k*k }
        subject.default_proc = p
        subject.default_proc.should be p
      end
      it "{}[2] should be 4 when default_proc=proc{|h,k| k*k}" do
        subject.default_proc = proc {|h,k| k*k }
        subject[2].should == 4
      end
      it "{}[2] should be 4 when default_proc=proc{|h,k| h[k]=k*k}" do
        subject.default_proc = proc {|h,k| h[k]=k*k }
        subject[2].should == 4
      end
      it "default_proc=proc{|h,k| k*k} should not add items" do
        subject.default_proc = proc {|h,k| k*k }
        subject[2]
        subject.should be_empty
      end
      it "default_proc=proc{|h,k| h[k]=k*k} should add items" do
        subject.default_proc = proc {|h,k| h[k]=k*k }
        subject[2].should
        subject.length.should == 1
      end
    end
  end

  describe "#delete" do
    it "{:a => obj}.delete(:a) should return obj" do
      subject.replace({:a => obj})
      subject.delete(:a).should be obj
    end
    it "{:a => obj}.delete(:b) should return nil" do
      subject.replace({:a => nil})
      subject.delete(:b).should be_nil
    end
    it "{:a => obj}.delete(:a){|k| :x} should return obj" do
      subject.replace({:a => obj})
      subject.delete(:a){|k| :x}.should be obj
    end
    it "{:a => obj}.delete(:b){|k| :x} should return :x" do
      subject.replace({:a => obj})
      subject.delete(:b){|k| :x}.should be :x
    end
    it "#key?(:a) should be false after #delete(:a)" do
      subject.replace({:a => obj})
      subject.delete(:a)
      subject.key?(:a).should be_false
    end
  end

  describe "#delete_if" do
    it "should return self" do
      subject.delete_if{|k,v| true}.should be subject
    end
    it "{:a=>obj,:b=>obj}.delete_if{|k,v| v.equal? obj} should be empty" do
      subject.replace({:a => obj, :b => obj})
      subject.delete_if{|k,v| v.equal? obj}.should be_empty
    end
    it "{:a=>obj,:b=>1}.delete_if{|k,v| v.equal? obj} should equal {:b=>1}" do
      subject.replace({:a => obj, :b => 1})
      hash2 = described_class.new.replace({:b=>1})
      subject.delete_if{|k,v| v.equal? obj}.should == hash2
    end
    it "should modify self" do
      subject.replace({:a => obj, :b => obj})
      subject.delete_if{|k,v| v.equal? obj}
      subject.should be_empty
    end
  end

  describe "#each" do
    it "should return self" do
      subject.each{|k,v|}.should be subject
    end
    it "{}.each should not execute block" do
      receiver = mock()
      receiver.expects(:receive).never
      subject.each {|k,v| receiver.receive(k,v)}
    end
    it "{:a=>obj}.each should execute block once with |:a,obj|" do
      receiver = mock()
      receiver.expects(:receive).once.with(:a,obj)
      subject.replace({:a => obj})
      subject.each {|k,v| receiver.receive(k,v)}
    end
    it "{:a=>obj,:b=>:B}.each should execute block twice" do
      receiver = mock()
      receiver.expects(:receive).once.with(:a,obj)
      receiver.expects(:receive).once.with(:b,:B)
      subject.replace({:a => obj,:b=>:B})
      subject.each {|k,v| receiver.receive(k,v)}
    end
  end

  describe "#each_key" do
    it "should return self" do
      subject.each_key{|k|}.should be subject
    end
    it "{}.each_key should not execute block" do
      receiver = mock()
      receiver.expects(:receive).never
      subject.each_key {|k| receiver.receive(k)}
    end
    it "{:a=>obj}.each_key should execute block once with (:a)" do
      receiver = mock()
      receiver.expects(:receive).once.with(:a)
      subject.replace({:a => obj})
      subject.each_key {|k| receiver.receive(k)}
    end
    it "{:a=>obj,:b=>:B}.each_key should execute block twice" do
      receiver = mock()
      receiver.expects(:receive).once.with(:a)
      receiver.expects(:receive).once.with(:b)
      subject.replace({:a => obj,:b=>:B})
      subject.each_key {|k| receiver.receive(k)}
    end
  end

  # duplicate of: each
  describe "#each_pair" do
    it "should return self" do
      subject.each_pair{|k,v|}.should be subject
    end
    it "{}.each_pair should not execute block" do
      receiver = mock()
      receiver.expects(:receive).never
      subject.each_pair {|k,v| receiver.receive(k,v)}
    end
    it "{:a=>obj}.each_pair should execute block once with |:a,obj|" do
      receiver = mock()
      receiver.expects(:receive).once.with(:a,obj)
      subject.replace({:a => obj})
      subject.each_pair {|k,v| receiver.receive(k,v)}
    end
    it "{:a=>obj,:b=>:B}.each_pair should execute block twice" do
      receiver = mock()
      receiver.expects(:receive).once.with(:a,obj)
      receiver.expects(:receive).once.with(:b,:B)
      subject.replace({:a => obj,:b=>:B})
      subject.each_pair {|k,v| receiver.receive(k,v)}
    end
  end
  
  describe "#each_value" do
    it "should return self" do
      subject.each_value{|v|}.should be subject
    end
    it "{}.each_value should not execute block" do
      receiver = mock()
      receiver.expects(:receive).never
      subject.each_value {|v| receiver.receive(v)}
    end
    it "{:a=>obj}.each_value should execute block once with (obj)" do
      receiver = mock()
      receiver.expects(:receive).once.with(obj)
      subject.replace({:a => obj})
      subject.each_value {|v| receiver.receive(v)}
    end
    it "{:a=>obj,:b=>:B}.each_value should execute block twice" do
      receiver = mock()
      receiver.expects(:receive).once.with(obj)
      receiver.expects(:receive).once.with(:B)
      subject.replace({:a => obj,:b=>:B})
      subject.each_value {|v| receiver.receive(v)}
    end
  end

  describe "#empty?" do
    it "should be true initially" do
      subject.empty?.should be_true
    end
    it "{:a => obj}.empty? should be false" do
      subject.replace({:a => obj})
      subject.empty?.should be_false
    end
  end

  describe "#eql?" do
    it "hash.eql?(hash) should be true" do
      subject.eql?(subject).should be_true
    end
    it "hash.eql?(hash.clone) should be true" do
      subject.eql?(subject.clone).should be_true
    end
    it "{}.eql?({:a => obj}) should be false" do
      hash2 = subject.clone.replace({:a => obj})
      subject.eql?(hash2).should be_false
    end
    it "{:a => :A}.eql?({:a => :B}) should be false" do
      subject.replace({:a => :A})
      hash2 = described_class.new.replace({:a => :B})
      subject.eql?(hash2).should be_false
    end
  end

  describe "#fetch" do
    it "{ :a => obj }.fetch(:a) should return obj" do
      subject.replace({:a => obj})
      subject.fetch(:a).should be obj
    end
    it "{ :a => :A }.fetch('a',obj) should return obj" do
      subject.replace({:a => :A})
      subject.fetch('a',obj).should be obj
    end
    it "{ :a => :A }.fetch('a') should raise IndexError" do
      subject.replace({:a => :A})
      expect { subject.fetch('a') }.to raise_error IndexError
    end
    it "{ :a => :A }.fetch(:a){|k| block} should not execute block" do
      receiver = mock()
      subject.replace({:a => :A})
      receiver.expects(:receive).never
      subject.fetch(:a) {|k| receiver.receive(k) }
    end
    it "{ :a => :A }.fetch(:b){|k| block} should execute block once with |:b|" do
      receiver = mock()
      subject.replace({:a => :A})
      receiver.expects(:receive).once.with(:b)
      subject.fetch(:b) {|k| receiver.receive(k) }
    end
  end

  if ruby_version >= 0x010901
    describe "#flatten" do
      it "{}.flatten should return []" do
        subject.flatten.should == []
      end
      it "{:a=>:A,:b=>:B}.flatten should return [:a,:A,:b,:B]" do
        subject.replace({:a=>:A,:b=>:B})
        subject.flatten.should == [:a,:A,:b,:B]
      end
      it "{:a=>[:A,:B]}.flatten should return [:a,[:A,:B]]" do
        subject.replace({:a=>[:A,:B]})
        subject.flatten.should == [:a,[:A,:B]]
      end
      it "{:a=>[:A,:B]}.flatten(2) should return [:a,:A,:B]" do
        subject.replace({:a=>[:A,:B]})
        subject.flatten(2).should == [:a,:A,:B]
      end
    end
  end

  describe "#has_key?" do
    it "{}.has_key?(:a) should return false" do
      subject.has_key?(:a).should be_false
    end
    it "{:a=>:A}.has_key?(:a) should return true" do
      subject.replace({:a => :A})
      subject.has_key?(:a).should be_true
    end
    it "{:a=>:A}.has_key?(:b) should return false" do
      subject.replace({:a => :A})
      subject.has_key?(:b).should be_false
    end
  end

  describe "#has_value?" do
    it "{}.has_value?(:A) should return false" do
      subject.has_value?(:A).should be_false
    end
    it "{:a=>:A}.has_value?(:A) should return true" do
      subject.replace({:a => :A})
      subject.has_value?(:A).should be_true
    end
    it "{:a=>:A}.has_value?(:B) should return false" do
      subject.replace({:a => :A})
      subject.has_value?(:B).should be_false
    end
  end

  describe "#hash" do
    it "should return fixed number" do
      subject.hash.should be_instance_of Fixnum
    end
    it "{}.fixnum should be zero" do
      subject.hash.should be_zero
    end
    it "{:a => :A}.fixnum should not be zero" do
      subject.replace({:a => :A})
      subject.hash.should_not be_zero
    end
  end

  # duplicate of: has_key?
  describe "#include?" do
    it "{}.include?(:a) should return false" do
      subject.include?(:a).should be_false
    end
    it "{:a=>:A}.include?(:a) should return true" do
      subject.replace({:a => :A})
      subject.include?(:a).should be_true
    end
    it "{:a=>:A}.include?(:b) should return false" do
      subject.replace({:a => :A})
      subject.include?(:b).should be_false
    end
  end

  describe "#invert" do
    it "hash.invert should return an instance of hash.class" do
      subject.invert.should be_instance_of subject.class
    end
    it "{:a => :A}.invert should be {:A => :a}" do
      subject.replace({:a => :A})
      hash2 = described_class.new.replace({:A => :a})
      subject.invert.should == hash2
    end
    it "{:a=>:A,:b=>:A}.invert should be {:A=>:b}" do
      subject.replace({:a => :A, :b => :A})
      hash2 = described_class.new.replace({:A => :b})
      subject.invert.should == hash2
    end
    it "should not modify self" do
      subject.replace({:a => :A, :b => :A})
      subject.invert
      subject.size.should == 2
    end
  end

  if ruby_version >= 0x010903
    describe "#keep_if" do
      it "should return self" do
        subject.keep_if{|k,v| true}.should be subject
      end
      it "{:a=>A,:b=>:B}.keep_if{|k,v| v.equal? :C} should be empty" do
        subject.replace({:a => :A, :b => :B})
        subject.keep_if{|k,v| v.equal? :C}.should be_empty
        subject.should be_empty
      end
      it "{:a=>obj,:b=>:B}.keep_if{|k,v| v.equal? obj} should be {:a=>obj}" do
        subject.replace({:a => obj, :b => :B})
        hash2 = described_class.new.replace({:a => obj})
        subject.keep_if{|k,v| v.equal? obj}.should == hash2
        subject.should == hash2
      end
    end
  end

  if ruby_version >= 0x010901
    describe "#key" do
      it "{}.key(:A) should be nil" do
        subject.key(:A).should be_nil
      end
      it "{:a=>:A,:b=>:B}.key(:A) should be :a" do
        subject.replace({ :a => :A, :b => :B })
        subject.key(:A).should be :a
      end
      it "{:a=>:A,:b=>:B}.key(:B) should be :b" do
        subject.replace({ :a => :A, :b => :B })
        subject.key(:B).should be :b
      end
      it "{:a=>:B,:b=>:B}.key(:B) should be :a" do
        subject.replace({ :a => :B, :b => :B })
        subject.key(:B).should be :a
      end
    end
  end

  # duplicate of: has_key?
  describe "#key?" do
    it "{}.key?(:a) should return false" do
      subject.key?(:a).should be_false
    end
    it "{:a=>:A}.key?(:a) should return true" do
      subject.replace({:a => :A})
      subject.key?(:a).should be_true
    end
    it "{:a=>:A}.key?(:b) should return false" do
      subject.replace({:a => :A})
      subject.key?(:b).should be_false
    end
  end

  describe "#keys" do
    it "{}.keys should equal []" do
      subject.keys.should == []
    end
    it "{:a=>:A,:b=>:B}.keys should equal [:a,:b]" do
      subject.replace({ :a => :A, :b => :B })
      subject.keys.should == [:a,:b]
    end
  end

  describe "#length" do
    it "should be Fixnum" do
      subject.length.should be_instance_of Fixnum
    end
    it "{}.length should be zero" do
      subject.length.should be_zero
    end
    it "{:a=>:A}.length should equal 1" do
      subject.replace({ :a => :A })
      subject.length.should == 1
    end
    it "{:a=>:A,:b=>:B}.length should equal 2" do
      subject.replace({ :a => :A, :b => :B })
      subject.length.should == 2
    end
  end

  # duplicate of: has_key?
  describe "#member?" do
    it "{}.member?(:a) should return false" do
      subject.member?(:a).should be_false
    end
    it "{:a=>:A}.member?(:a) should return true" do
      subject.replace({:a => :A})
      subject.member?(:a).should be_true
    end
    it "{:a=>:A}.member?(:b) should return false" do
      subject.replace({:a => :A})
      subject.member?(:b).should be_false
    end
  end
  
  describe "#merge" do
    it "should return new hash" do
      hash2 = described_class.new
      subject.merge(hash2).should be_instance_of subject.class
    end
    it "{:a=>:A}.merge({:b=>:B}) should equal {:a=>:A,:b=>:B}" do
      subject.replace({ :a => :A })
      hash2 = described_class.new.replace({ :b => :B })
      hash3 = described_class.new.replace({ :a => :A, :b => :B })
      subject.merge(hash2).should == hash3
    end
    it "{:a=>:A}.merge({:a=>:B}) should equal {:a=>:B}" do
      subject.replace({ :a => :A })
      hash2 = described_class.new.replace({ :a => :B })
      subject.merge(hash2).should == hash2
    end
    it "should not modify self" do
      hash2 = described_class.new.replace({ :a => :A })
      hash3 = described_class.new
      subject.merge(hash2)
      subject.should == hash3
    end
  end

  # duplicate of: update
  describe "#merge!" do
    it "should return self" do
      hash2 = described_class.new
      subject.merge!(hash2).should be subject
    end
    it "{:a=>:A}.merge!({:b=>:B}) should equal {:a=>:A,:b=>:B}" do
      subject.replace({ :a => :A })
      hash2 = described_class.new.replace({ :b => :B })
      hash3 = described_class.new.replace({ :a => :A, :b => :B })
      subject.merge!(hash2).should == hash3
    end
    it "{:a=>:A}.merge!({:a=>:B}) should equal {:a=>:B}" do
      subject.replace({ :a => :A })
      hash2 = described_class.new.replace({ :a => :B })
      subject.merge!(hash2).should == hash2
    end
    it "should modify self" do
      hash2 = described_class.new.replace({ :a => :A })
      subject.merge!(hash2)
      subject.should == hash2
    end
  end

  if ruby_version >= 0x010901
    describe "#rassoc" do
      it "{'a' => 'A'}.assoc('A') should return ['a','A']" do
        subject.replace({'a' => 'A'})
        subject.rassoc('A').should == ['a', 'A']
      end
      it "{'a' => 'A'}.assoc('B') should return nil" do
        subject.replace({'a' => 'A'})
        subject.rassoc('B').should be_nil
      end
    end
  end

  describe "#rehash" do
    it "should return self" do
      subject.rehash.should be subject
    end
  end

  describe "#reject" do
    it "should return instance of hash.class" do
      subject.replace({ :a => :A })
      subject.reject{|k,v| true}.should be_instance_of subject.class
    end
    it "{:a=>obj,:b=>obj}.reject{|k,v| v.equal? obj} should be empty" do
      subject.replace({:a => obj, :b => obj})
      subject.reject{|k,v| v.equal? obj}.should be_empty
    end
    it "{:a=>obj,:b=>1}.reject{|k,v| v.equal? obj} should equal {:b=>1}" do
      subject.replace({:a => obj, :b => 1})
      hash2 = described_class.new.replace({:b=>1})
      subject.reject{|k,v| v.equal? obj}.should == hash2
    end
    it "should not modify self" do
      subject.replace({:a => obj, :b => obj})
      subject.reject{|k,v| v.equal? obj}
      subject.should_not be_empty
    end
  end

  describe "#reject!" do
    it "should return nil when no changes where done" do
      subject.reject!{|k,v| false}.should be_nil
    end
    it "should return self when changes were done" do
      subject.replace({ :a => :A })
      subject.reject!{|k,v| true}.should be subject
    end
    it "{:a=>obj,:b=>obj}.reject!{|k,v| v.equal? obj} should be empty" do
      subject.replace({:a => obj, :b => obj})
      subject.reject!{|k,v| v.equal? obj}.should be_empty
    end
    it "{:a=>obj,:b=>1}.reject!{|k,v| v.equal? obj} should equal {:b=>1}" do
      subject.replace({:a => obj, :b => 1})
      hash2 = described_class.new.replace({:b=>1})
      subject.reject!{|k,v| v.equal? obj}.should == hash2
    end
    it "should modify self" do
      subject.replace({:a => obj, :b => obj})
      subject.reject!{|k,v| v.equal? obj}
      subject.should be_empty
    end
  end

  describe "#replace" do
    it "should return self" do
      hash2 = described_class.new
      subject.replace(hash2).should be subject
    end
    it "{:a=>:A}.replace({:b=>:B}) should equal {:b=>:B}" do
      subject.replace({ :a => :A })
      hash2 = described_class.new.replace({ :b => :B })
      subject.replace(hash2).should == hash2
    end
    it "should modify self" do
      hash2 = described_class.new.replace({ :a => :A })
      subject.replace(hash2)
      subject.should == hash2
    end
  end

  describe "#select" do
    # I know that Hash#select returns an array on ruby 1.8, but I don't care.
    # It should return a hash, and I fix it in Vash!
    it "should return instance of hash.class" do
      subject.select{|k,v| true}.should be_instance_of subject.class
    end
    it "{:a=>:A,:b=>:B}.select{|k,v| v.equal? :C} should be empty" do
      subject.replace({:a => :A, :b => :B})
      subject.select{|k,v| v.equal? :C}.should be_empty
    end
    it "{:a=>obj,:b=>1}.select{|k,v| v.equal? obj} should equal {:a=>obj}" do
      subject.replace({:a => obj, :b => 1})
      hash2 = described_class.new.replace({:a=>obj})
      subject.select{|k,v| v.equal? obj}.should == hash2
    end
    it "should not modify self" do
      subject.replace({:a => :A, :b => :B})
      subject.select{|k,v| v.equal? :C}
      subject.should_not be_empty
    end
  end

  if ruby_version >= 0x010903
    describe "#select!" do
      it "should return nil when nothing was changed" do
        subject.select!{|k,v| true}.should be nil
      end
      it "should return self when something was changed" do
        subject.replace({:a => :A})
        subject.select!{|k,v| false}.should be subject
      end
      it "{:a=>:A,:b=>:B}.select!{|k,v| v.equal? :C} should be empty" do
        subject.replace({:a => :A, :b => :B})
        subject.select!{|k,v| v.equal? :C}.should be_empty
      end
      it "{:a=>obj,:b=>1}.select!{|k,v| v.equal? obj} should equal {:a=>obj}" do
        subject.replace({:a => obj, :b => 1})
        hash2 = described_class.new.replace({:a=>obj})
        subject.select!{|k,v| v.equal? obj}.should == hash2
      end
      it "should modify self" do
        subject.replace({:a => :A, :b => :B})
        subject.select!{|k,v| v.equal? :C}
        subject.should be_empty
      end
    end
  end

  describe "#shift" do
    it "{}.shift should return nil" do
      subject.shift.should be_nil
    end
    it "{:a => :A}.shift should return [:a, :A]" do
      subject.replace({ :a => :A })
      subject.shift.should == [:a, :A]
    end
    it "should remove first item from hash" do
      subject.replace({ :a => :A, :b => :B })
      hash2 = described_class.new.replace({:b => :B})
      subject.shift
      subject.should == hash2
    end
  end

  # duplicate of: length
  describe "#size" do
    it "should be Fixnum" do
      subject.size.should be_instance_of Fixnum
    end
    it "{}.size should be zero" do
      subject.size.should be_zero
    end
    it "{:a=>:A}.size should equal 1" do
      subject.replace({ :a => :A })
      subject.size.should == 1
    end
    it "{:a=>:A,:b=>:B}.size should equal 2" do
      subject.replace({ :a => :A, :b => :B })
      subject.size.should == 2
    end
  end

  # duplicate of: []=
  describe "#store" do
    it "#store('a',obj) should return obj" do
      subject.store('a',obj).should be obj
    end
    it "#['a'] should return obj after #store('a',obj)" do
      subject.store('a',obj)
      subject['a'].should be obj
    end
  end

  describe "#to_a" do
    it "should return an array" do
      subject.to_a.should be_instance_of Array
    end
    it "{:a=>:A,:b=>:B}.to_a should be [[:a,:A],[:b,:B]]" do
      subject.replace({ :a => :A, :b => :B })
      subject.to_a.should == [[:a,:A],[:b,:B]]
    end
  end

  if ruby_version >= 0x020000
    describe "#to_h" do
      it "should return a Hash" do
        subject.to_h.should be_instance_of Hash
      end
      it "obj.to_h == obj should be true" do
        subject.to_h.should == subject
      end
    end
  end
  
  describe "#to_hash" do
    it "should return a hash" do
      subject.to_hash.should be_a Hash
    end
  end

  describe "#update" do
    it "should return self" do
      hash2 = described_class.new
      subject.update(hash2).should be subject
    end
    it "{:a=>:A}.update({:b=>:B}) should equal {:a=>:A,:b=>:B}" do
      subject.replace({ :a => :A })
      hash2 = described_class.new.replace({ :b => :B })
      hash3 = described_class.new.replace({ :a => :A, :b => :B })
      subject.update(hash2).should == hash3
    end
    it "{:a=>:A}.update({:a=>:B}) should equal {:a=>:B}" do
      subject.replace({ :a => :A })
      hash2 = described_class.new.replace({ :a => :B })
      subject.update(hash2).should == hash2
    end
    it "should modify self" do
      hash2 = described_class.new.replace({ :a => :A })
      subject.update(hash2)
      subject.should == hash2
    end
  end

  # duplicate of: has_value?
  describe "#value?" do
    it "{}.value?(:A) should return false" do
      subject.value?(:A).should be_false
    end
    it "{:a=>:A}.value?(:A) should return true" do
      subject.replace({:a => :A})
      subject.value?(:A).should be_true
    end
    it "{:a=>:A}.value?(:B) should return false" do
      subject.replace({:a => :A})
      subject.value?(:B).should be_false
    end
  end

  describe "#values" do
    it "{}.values should equal []" do
      subject.values.should == []
    end
    it "{:a=>:A,:b=>:B}.values should equal [:A,:B]" do
      subject.replace({ :a => :A, :b => :B })
      subject.values.should == [:A,:B]
    end
  end

  describe "#values_at" do
    it "{}.values_at should equal []" do
      subject.values_at.should == []
    end
    it "{:a => :A}.values_at should equal []" do
      subject.replace({ :a => :A })
      subject.values_at.should == []
    end
    it "{}.values_at(:a,:b) should equal [nil,nil]" do
      subject.values_at(:a,:b).should == [nil,nil]
    end
    it "{:a=>:A,:b=>:B,:c=>:C}.values_at(:a,:c) should equal [:A,:C]" do
      subject.replace({ :a => :A, :b => :B, :c => :C })
      subject.values_at(:a,:c).should == [:A,:C]
    end
  end

end
