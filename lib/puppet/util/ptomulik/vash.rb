require 'puppet/util/ptomulik'

# Vash provides mixins that add Hash interface to classes. The mixins allow you
# to enable simple data validation and munging, such that you may define
# restrictions on keys, values and pairs entering your hash.
#
# There are two patterns to add Vash functionality to your class. The first one
# is to use {Puppet::Util::PTomulik::Vash::Contained} mixin, as follows
#
#     class MyVash
#       include Puppet::Util::PTomulik::Vash::Contained
#     end
#
# The second pattern is to use {Puppet::Util::PTomulik::Vash::Inherited}
#
#     class MyVash < Hash
#       include Puppet::Util::PTomulik::Vash::Inherited
#     end
#
# With the first pattern, the data is keept in an instance variable
# `@vash_underlying_hash` and you dont have to inherit Hash. In second pattern,
# the superclass of `MyVash` is used to keep hash data and this superclass
# should have Hash functionality.
#
#
# See documentation for
#
# * {Contained}
# * {Inherited}
#
# you may also wish to consult
#
# * {Validator}.
#
module Puppet::Util::PTomulik::Vash
end
