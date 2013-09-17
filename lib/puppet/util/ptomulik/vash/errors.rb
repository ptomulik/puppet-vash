require 'puppet/util/ptomulik/vash'
module Puppet::Util::PTomulik::Vash

  class VashArgumentError < ::ArgumentError; end
  class InvalidKeyError < VashArgumentError; end
  class InvalidValueError < VashArgumentError; end
  class InvalidPairError < VashArgumentError; end
  class OddArgNoError < VashArgumentError; end

end
