require 'spec_helper'
require 'puppet/util/ptomulik/vash'
require 'unit/puppet/shared_behaviours/vash'

class Vash_Contained
  include Puppet::Util::PTomulik::Vash::Contained
  def initialize_copy(other)
    super(other)
  end
end
describe Vash_Contained do
  include_examples "Vash"
end
class Vash_Inherited < Hash
  include Puppet::Util::PTomulik::Vash::Inherited
end
describe Vash_Inherited do
  include_examples "Vash"
end
