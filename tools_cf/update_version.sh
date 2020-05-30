#~/usr/bin/env bash
#
# Update version

if [[ "$charts_ver" == "" ]]; then
	echo charts_ver environment variable must be set
	exit 1
fi

# Change version
ver="s|version: .*$|version: $charts_ver|"
cover="s|charts_common_cf: .*$|charts_common_cf: ^$charts_ver|"
find . -type f -name 'pubspec.yaml' -print0 | xargs -0 \
   sed -i -e "${ver} ; ${cover}"

