#~/usr/bin/env bash
#
# Run tests on charts_connon_cf and charts_flutter_cf.
#
# To test that this scripts detects errors pass "fail_common" or
# "fail_flutter" to this script as the first parameter
# For Example:
#  ./tools_cf/test.sh fail_flutter

# Disable exiting immediately on errors
set +e

# The test_this variable, expected to be:
#   ""             if not testing of this script
#   "fail_common"  to test charts_common_cf
#   "fail_flutter" to test charts_flutter_cf
test_this=$1

# Enter charts_common_cf
cd charts_common_cf

# Get packages, exit if an error
pub get
result=$?
[ $result -ne 0 ] && (echo "${PWD##*/} pub get: Error=$result"; exit $result;)

# Copy failing_test if we are testing this script
[ "$test_this" = "fail_common" ] && cp ../tools_cf/failing_test.dart test/

# Run the tests and exit if failures
pub run test
result=$?
if [ $result -ne 0 ]; then
  echo "${PWD##*/} pub run test: Error=$result"
  [ "$test_this" = "fail_common" ] && rm test/failing_test.dart
  exit $result
fi

# Enter charts_flutter_cf
cd ../charts_flutter_cf

# Get packages, exit if an error
flutter pub get
result=$?
[ $result -ne 0 ] && (echo "${PWD##*/} flutter pub get: Error=$result"; exit $result;)

# Copy failing_test if we are testing this script
[ "$test_this" = "fail_flutter" ] && cp ../tools_cf/failing_test.dart test/

# Run the tests and exit if failure
flutter test
result=$?
if [ $result -ne 0 ]; then
  echo "${PWD##*/} flutter test: Error=$result"
  [ "$test_this" = "fail_flutter" ] && rm test/failing_test.dart
  exit $result
fi

# success
echo success
