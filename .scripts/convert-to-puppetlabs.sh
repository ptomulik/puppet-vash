#! /bin/sh

set -e

# copy sources to .tmp/lib/puppet and refactor them such that they're good to
# be merged back to puppet project
#
# if argument provided, it should be a path to original puppet, the script then
# shows diff

ROOT=$(readlink -f "$(dirname $0)/..")
SOURCE="."
TARGET=".tmp/vash"

function do_convert {
  rm -rf "${TARGET}/lib/puppet" "${TARGET}/spec"
  find "${SOURCE}/lib/puppet" "${SOURCE}/spec/unit" -type f | grep -v '\.swp$' | while read F; do
      F2=$(echo $F | sed -e "s:^${SOURCE}:${TARGET}:" \
                         -e 's/ptomulik\/vash/vash/g' \
                         -e 's/unit\/puppet/unit/g' \
                         -e 's/unit\/shared_behaviours/shared_behaviours/g');
      D2=$(dirname $F2);
      test -e $D2 || mkdir -p $D2;
      # Some excludes ...
      test "${SOURCE}/lib/puppet/util/ptomulik.rb" '=' "$F" &&  continue;
      # Finally copy the files
      cp $F $F2;
    done
  cp "${SOURCE}/README.md" "${TARGET}/lib/puppet/util/vash/"
  find "${TARGET}/lib/puppet" "${TARGET}/spec" -type f | grep -v '\.swp$' | xargs sed -i \
      -e '/^\s*#\s*VASH_DELETE_START/,/^\s*#\s*VASH_DELETE_END/d' \
      -e '/^\s*#\s*VASH_COMMENTOUT_START/,/^\s*#\s*VASH_COMMENTOUT_END/s/^/##/' \
      -e '/^\s*##\s*VASH_UNCOMMENT_START/,/^\s*##\s*VASH_UNCOMMENT_END/s/^#//' \
      -e 's/PTomulik::Vash/Vash/g' \
      -e 's/ptomulik\/vash/vash/g' \
      -e 's/util\/ptomulik/util/g' \
      -e 's/unit\/puppet/unit/g' \
      -e 's/unit\/shared_behaviours/shared_behaviours/g' \
      -e 's/module PTomulik;\s*module Vash;\s*end;\s*end/module Vash; end/g' \
      -e 's/module PTomulik;\s*end;//g'
}

(cd $ROOT && do_convert)
echo "conversion complete, results went to ${ROOT}/${TARGET}"
