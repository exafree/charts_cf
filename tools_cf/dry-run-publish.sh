#~/usr/bin/env bash
#
# Do a dry run for publishing
#
# Currently the dry-run always fails because the
# charts_flutter_cf/pubspec.yaml uses a path to find
# charts_common_cf so it fails.

# Disable exiting immediately on errors
set +e

# Enter charts_common_cf
cd charts_common_cf

# Get packages, exit if an error
pub get
result=$?
echo result=$result
if [ $result -ne 0 ]; then
	echo "${PWD##*/} pub get: Error=$result"
	set -e
	exit $result
fi

# Do dry-run publish
pub publish --dry-run
result=$?
echo result=$result
if [ $result -ne 0 ]; then
	echo "${PWD##*/} pub publish --dry-run: Error=$result"
	set -e
	exit $result
fi;

# Enter charts_flutter_cf
cd ../charts_flutter_cf

# Get packages, exit if an error
flutter pub get
result=$?
echo result=$result
if [ $result -ne 0 ]; then
      echo "${PWD##*/} pub get: Error=$result"
      set -e
      exit $result
fi

# Change to published reference to charts_common_cf instead of using path
# in charts_flutter_cf/pubspec.yaml
uncmnt_co='s|# charts_common_cf: \^0.10.0|charts_common_cf: ^0.10.0|'
cmnt_co='s|^  charts_common_cf:$|  # charts_common_cf:|'
cmnt_pt='s|^    path: ../charts_common_cf/$|  #   path: ../charts_common_cf/|'
sed -i -e "${uncmnt_co} ; ${cmnt_co} ; ${cmnt_pt}" pubspec.yaml

# Do dry-run publish
flutter pub publish --dry-run
result=$?
echo result=$result
if [ $result -ne 0 ]; then
       echo "${PWD##*/} flutter pub publish --dry-run: Error=$result"
       set -e
       exit $result
fi

# Change back to using path
# in charts_flutter_cf/pubspec.yaml
cmnt_co='s|^  charts_common_cf: \^0.10.0|  # charts_common_cf: ^0.10.0|'
uncmnt_co='s|^  # charts_common_cf:$|  charts_common_cf:|'
uncmnt_pt='s|^  #   path: ../charts_common_cf/$|    path: ../charts_common_cf/|'
sed -i -e "${cmnt_co} ; ${uncmnt_co} ; ${uncmnt_pt}" pubspec.yaml

# success
echo success
